package shared

import (
	"encoding/xml"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"
)

type TestCase struct {
	XMLName   xml.Name `xml:"testcase"`
	Name      string   `xml:"name,attr"`
	ClassName string   `xml:"classname,attr"`
	Failure   *Failure `xml:"failure,omitempty"`
	Time      string   `xml:"time,attr"`
}

type Failure struct {
	Message string `xml:"message,attr"`
	Type    string `xml:"type,attr"`
	Body    string `xml:",chardata"`
}

type TestSuite struct {
	XMLName  xml.Name   `xml:"testsuite"`
	Name     string     `xml:"name,attr"`
	Tests    int        `xml:"tests,attr"`
	Failures int        `xml:"failures,attr"`
	Time     string     `xml:"time,attr"`
	Cases    []TestCase `xml:"testcase"`
}

var testStartTime = time.Now()

func FinalizeJUnitReportSummary() {
	duration := time.Since(testStartTime)
	fmt.Printf("📘 JUnit Summary: Unit test suite completed in %s\n", duration)

	// Optionally write summary to a report file
	reportFile := "junit-summary.txt"
	f, err := os.Create(reportFile)
	if err != nil {
		fmt.Printf("⚠️ Failed to write summary to file: %v\n", err)
		return
	}
	defer f.Close()

	fmt.Fprintf(f, "Test suite completed in %s\n", duration)
}

func WriteJUnitReport(results []string, isIntegration bool, suiteName string, reportDir string, reportFile string) {
	suite := TestSuite{Name: suiteName}

	for _, r := range results {
		name := strings.TrimPrefix(r, "✅ ")
		name = strings.TrimPrefix(name, "❌ ")
		caseResult := TestCase{
			Name:      name,
			ClassName: "vpc_test",
			Time:      "0",
		}
		if strings.HasPrefix(r, "❌") {
			caseResult.Failure = &Failure{
				Message: "test failed",
				Type:    "failure",
				Body:    fmt.Sprintf("%s failed", name),
			}
			suite.Failures++
		}
		suite.Cases = append(suite.Cases, caseResult)
	}
	suite.Tests = len(results)

	_ = os.MkdirAll(reportDir, 0755)
	file, err := os.Create(fmt.Sprintf("%s/%s", reportDir, reportFile))
	if err != nil {
		fmt.Println("Error creating JUnit report file:", err)
		return
	}
	defer file.Close()

	xmlEncoder := xml.NewEncoder(file)
	xmlEncoder.Indent("", "  ")
	if err := xmlEncoder.Encode(suite); err != nil {
		fmt.Println("Error encoding JUnit XML:", err)
	}
}

func WrapWithJUnit(t *testing.T) *testing.T {
	start := time.Now()
	t.Cleanup(func() {
		duration := time.Since(start)
		fmt.Printf("📘 JUnit: %s completed in %s\n", t.Name(), duration)
	})
	return t
}
