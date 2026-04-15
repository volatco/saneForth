package main

import (
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"syscall"
	"time"
)

var ttyUSBPattern = regexp.MustCompile(`ttyUSB([0-9]+)$`)

type checkStatus string

const (
	statusPass checkStatus = "PASS"
	statusWarn checkStatus = "WARN"
	statusFail checkStatus = "FAIL"
)

type checkResult struct {
	Name    string      `json:"name"`
	Status  checkStatus `json:"status"`
	Details string      `json:"details"`
}

type report struct {
	Timestamp       string        `json:"timestamp"`
	RepoRoot        string        `json:"repo_root"`
	PreferredPort   string        `json:"preferred_port"`
	DetectionReason string        `json:"detection_reason"`
	Checks          []checkResult `json:"checks"`
}

func main() {
	jsonOut := flag.Bool("json", false, "emit JSON report")
	containerFlag := flag.Bool("container", false, "container mode (relax host package/group checks)")
	flag.Parse()

	start := time.Now()
	repoRoot, err := detectRepoRoot()
	if err != nil {
		fail("could not detect repo root: %v", err)
	}

	containerMode := *containerFlag || detectContainer()

	var checks []checkResult
	checks = append(checks, checkRuntime(repoRoot))
	checks = append(checks, checkDialout(containerMode))
	checks = append(checks, checkTTYUSB())
	checks = append(checks, checkSerialByID())
	checks = append(checks, checkI386Packages(containerMode)...)

	portCmd, reason := detectPreferredPort()
	r := report{
		Timestamp:       time.Now().Format(time.RFC3339),
		RepoRoot:        repoRoot,
		PreferredPort:   portCmd,
		DetectionReason: reason,
		Checks:          checks,
	}

	if *jsonOut {
		enc := json.NewEncoder(os.Stdout)
		enc.SetIndent("", "  ")
		_ = enc.Encode(r)
	} else {
		printTextReport(r, time.Since(start))
	}

	if hasFailures(checks) {
		os.Exit(1)
	}
}

func detectRepoRoot() (string, error) {
	wd, err := os.Getwd()
	if err != nil {
		return "", err
	}

	cur := wd
	for {
		runtimePath := filepath.Join(cur, "af3", "sfux", "sf6a0.exe")
		if st, err := os.Stat(runtimePath); err == nil && !st.IsDir() {
			return cur, nil
		}
		parent := filepath.Dir(cur)
		if parent == cur {
			break
		}
		cur = parent
	}
	return "", errors.New("expected af3/sfux/sf6a0.exe not found from current path upward")
}

func checkRuntime(root string) checkResult {
	p := filepath.Join(root, "af3", "sfux", "sf6a0.exe")
	if st, err := os.Stat(p); err == nil && !st.IsDir() {
		return checkResult{Name: "runtime binary", Status: statusPass, Details: p}
	}
	return checkResult{Name: "runtime binary", Status: statusFail, Details: fmt.Sprintf("missing: %s", p)}
}

func checkDialout(containerMode bool) checkResult {
	out, err := run("id", "-nG")
	if err != nil {
		return checkResult{Name: "dialout group", Status: statusWarn, Details: "unable to query groups via id -nG"}
	}
	groups := strings.Fields(out)
	for _, g := range groups {
		if g == "dialout" {
			return checkResult{Name: "dialout group", Status: statusPass, Details: "user is in dialout"}
		}
	}
	if dev, ok := firstReadableWritableTTYUSB(); ok {
		return checkResult{Name: "dialout group", Status: statusPass, Details: fmt.Sprintf("user is not in dialout, but read/write access to %s is available", dev)}
	}
	if containerMode {
		return checkResult{Name: "dialout group", Status: statusWarn, Details: "user is not in dialout (container mode)"}
	}
	return checkResult{Name: "dialout group", Status: statusFail, Details: "user is not in dialout"}
}

func checkTTYUSB() checkResult {
	devs, _ := filepath.Glob("/dev/ttyUSB*")
	if len(devs) == 0 {
		return checkResult{Name: "serial ttyUSB", Status: statusFail, Details: "no /dev/ttyUSB* found"}
	}
	sort.Strings(devs)
	var mapped []string
	for _, d := range devs {
		if target, err := filepath.EvalSymlinks(d); err == nil && target != d {
			mapped = append(mapped, fmt.Sprintf("%s -> %s", d, target))
		} else {
			mapped = append(mapped, d)
		}
	}
	return checkResult{Name: "serial ttyUSB", Status: statusPass, Details: strings.Join(mapped, ", ")}
}

func checkSerialByID() checkResult {
	dir := "/dev/serial/by-id"
	entries, err := os.ReadDir(dir)
	if err != nil {
		return checkResult{Name: "serial by-id", Status: statusWarn, Details: fmt.Sprintf("unavailable: %s", dir)}
	}
	if len(entries) == 0 {
		return checkResult{Name: "serial by-id", Status: statusWarn, Details: "directory exists but has no entries"}
	}
	var paths []string
	for _, e := range entries {
		p := filepath.Join(dir, e.Name())
		target, err := filepath.EvalSymlinks(p)
		if err != nil {
			paths = append(paths, p)
			continue
		}
		paths = append(paths, fmt.Sprintf("%s -> %s", p, target))
	}
	sort.Strings(paths)
	return checkResult{Name: "serial by-id", Status: statusPass, Details: strings.Join(paths, ", ")}
}

func checkI386Packages(containerMode bool) []checkResult {
	pkgs := []string{"libncurses6:i386", "libc6:i386", "libstdc++6:i386"}
	if _, err := exec.LookPath("dpkg-query"); err != nil {
		return []checkResult{{
			Name:    "i386 packages",
			Status:  statusWarn,
			Details: "dpkg-query not found; skipping package checks",
		}}
	}
	var out []checkResult
	for _, pkg := range pkgs {
		statusOut, err := run("dpkg-query", "-W", "-f=${Status}\\n", pkg)
		if err != nil || !strings.Contains(statusOut, "install ok installed") {
			status := statusFail
			details := fmt.Sprintf("missing: %s", pkg)
			if containerMode {
				status = statusWarn
				details = fmt.Sprintf("missing in container image: %s", pkg)
			}
			out = append(out, checkResult{
				Name:    "i386 package",
				Status:  status,
				Details: details,
			})
			continue
		}
		out = append(out, checkResult{
			Name:    "i386 package",
			Status:  statusPass,
			Details: fmt.Sprintf("installed: %s", pkg),
		})
	}
	return out
}

func firstReadableWritableTTYUSB() (string, bool) {
	devs, _ := filepath.Glob("/dev/ttyUSB*")
	sort.Strings(devs)
	for _, d := range devs {
		if err := syscall.Access(d, 6); err == nil {
			return d, true
		}
	}
	return "", false
}

func detectContainer() bool {
	if _, err := os.Stat("/run/.containerenv"); err == nil {
		return true
	}
	if _, err := os.Stat("/.dockerenv"); err == nil {
		return true
	}
	return false
}

func detectPreferredPort() (string, string) {
	if idx := strings.TrimSpace(os.Getenv("VOLATCO_PORT_IDX")); idx != "" {
		if regexp.MustCompile(`^[0-9]+$`).MatchString(idx) {
			return idx + " PORT", "manual override VOLATCO_PORT_IDX"
		}
		return "1 PORT", "invalid VOLATCO_PORT_IDX; fallback"
	}

	if p, ok := detectFromPath("/dev/volatco-port-b"); ok {
		return p, "stable alias /dev/volatco-port-b"
	}
	if p, ok := detectFromGlob("/dev/serial/by-id/*VOLATCO_Port_B*"); ok {
		return p, "by-id VOLATCO_Port_B match"
	}
	if p, ok := detectFromGlob("/dev/serial/by-id/*VOLATCO*"); ok {
		return p, "by-id VOLATCO match"
	}

	ttys, _ := filepath.Glob("/dev/ttyUSB*")
	sort.Strings(ttys)
	if len(ttys) == 1 {
		if p, ok := portFromTTYPath(ttys[0]); ok {
			return p, "single ttyUSB device present"
		}
	}
	if _, err := os.Stat("/dev/ttyUSB1"); err == nil {
		return "1 PORT", "fallback ttyUSB1 exists"
	}
	if _, err := os.Stat("/dev/ttyUSB0"); err == nil {
		return "0 PORT", "fallback ttyUSB0 exists"
	}
	return "1 PORT", "default fallback"
}

func detectFromGlob(glob string) (string, bool) {
	matches, _ := filepath.Glob(glob)
	if len(matches) == 0 {
		return "", false
	}
	sort.Strings(matches)
	for _, m := range matches {
		if p, ok := detectFromPath(m); ok {
			return p, true
		}
	}
	return "", false
}

func detectFromPath(path string) (string, bool) {
	resolved, err := filepath.EvalSymlinks(path)
	if err != nil {
		return "", false
	}
	return portFromTTYPath(resolved)
}

func portFromTTYPath(path string) (string, bool) {
	m := ttyUSBPattern.FindStringSubmatch(path)
	if len(m) != 2 {
		return "", false
	}
	return m[1] + " PORT", true
}

func hasFailures(checks []checkResult) bool {
	for _, c := range checks {
		if c.Status == statusFail {
			return true
		}
	}
	return false
}

func printTextReport(r report, elapsed time.Duration) {
	fmt.Println("volatco-assist-go prototype")
	fmt.Printf("timestamp: %s\n", r.Timestamp)
	fmt.Printf("repo: %s\n", r.RepoRoot)
	fmt.Printf("autodetected runtime port: %s (%s)\n", r.PreferredPort, r.DetectionReason)
	fmt.Println()
	fmt.Println("checks:")
	for _, c := range r.Checks {
		fmt.Printf("- [%s] %s: %s\n", c.Status, c.Name, c.Details)
	}
	fmt.Println()
	fmt.Printf("elapsed: %s\n", elapsed.Round(time.Millisecond))
}

func run(name string, args ...string) (string, error) {
	cmd := exec.Command(name, args...)
	out, err := cmd.CombinedOutput()
	return strings.TrimSpace(string(out)), err
}

func fail(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "error: "+format+"\n", args...)
	os.Exit(2)
}
