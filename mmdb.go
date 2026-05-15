package main

// 基本都是 claude 写的

import (
	"bufio"
	"fmt"
	"log"
	"net"
	"os"
	"path/filepath"
	"strings"

	"github.com/maxmind/mmdbwriter"
	"github.com/maxmind/mmdbwriter/mmdbtype"
	"golang.org/x/text/language"
	"golang.org/x/text/language/display"
)

const (
	tmpFile    = "tmp.mmdb"
	outputFile = "output.mmdb"
)

var (
	en = display.English.Regions()
	zh = display.SimplifiedChinese.Regions()
)

func main() {
	writer, err := createWriter()
	if err != nil {
		log.Fatalf("Failed to create mmdb writer: %v", err)
	}

	for _, s := range []string{`ipv4`, `ipv6`} {
		cnt, err := processDirectory(writer, `dist/`+s)
		if err != nil {
			log.Fatalf("Failed to process %s: %v", s, err)
		}
		fmt.Printf("%s: %d networks\n", s, cnt)
	}

	if err := writeOutput(writer); err != nil {
		log.Fatalf("Failed to write output: %v", err)
	}
}

func createWriter() (*mmdbwriter.Tree, error) {
	return mmdbwriter.New(mmdbwriter.Options{
		DatabaseType: `Soulogic-IP2Country`,
		RecordSize:   28,
	})
}

func processDirectory(writer *mmdbwriter.Tree, dir string) (int, error) {
	files, err := listCountryFiles(dir)
	if err != nil {
		return 0, err
	}

	total := 0
	for _, file := range files {
		countryCode := extractCountryCode(file)
		count, err := processFile(writer, file, countryCode)
		if err != nil {
			log.Printf("Warning: error processing %s: %v", file, err)
			continue
		}
		fmt.Printf("  %s/%s.txt: %d networks\n", dir, countryCode, count)
		total += count
	}

	return total, nil
}

func listCountryFiles(dir string) ([]string, error) {
	pattern := filepath.Join(dir, "*.txt")
	files, err := filepath.Glob(pattern)
	if err != nil {
		return nil, fmt.Errorf("glob %s: %w", pattern, err)
	}
	if len(files) == 0 {
		return nil, fmt.Errorf("no .txt files found in %s", dir)
	}
	return files, nil
}

func extractCountryCode(filePath string) string {
	base := filepath.Base(filePath)
	name := strings.TrimSuffix(base, filepath.Ext(base))
	return strings.ToUpper(name)
}

func processFile(writer *mmdbwriter.Tree, filePath, countryCode string) (int, error) {
	f, err := os.Open(filePath)
	if err != nil {
		return 0, fmt.Errorf("open %s: %w", filePath, err)
	}
	defer f.Close()

	count := 0
	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		line := strings.TrimSpace(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		if err := insertCIDR(writer, line, countryCode); err != nil {
			log.Printf("  Skipping %s in %s: %v", line, filePath, err)
			continue
		}
		count++
	}

	if err := scanner.Err(); err != nil {
		return count, fmt.Errorf("scan %s: %w", filePath, err)
	}

	return count, nil
}

func insertCIDR(writer *mmdbwriter.Tree, cidr, countryCode string) error {
	_, network, err := net.ParseCIDR(cidr)
	if err != nil {
		return fmt.Errorf("invalid CIDR %q: %w", cidr, err)
	}

	cc := language.MustParseRegion(countryCode)

	record := mmdbtype.Map{
		"country": mmdbtype.Map{
			"iso_code": mmdbtype.String(countryCode),
			"names": mmdbtype.Map{
				"en": mmdbtype.String(en.Name(cc)),
				"zh": mmdbtype.String(zh.Name(cc)),
			},
		},
	}

	if err := writer.Insert(network, record); err != nil {
		return fmt.Errorf("insert %s: %w", cidr, err)
	}

	return nil
}

func writeOutput(writer *mmdbwriter.Tree) error {
	f, err := os.Create(tmpFile)
	if err != nil {
		return fmt.Errorf("create %s: %w", outputFile, err)
	}
	defer f.Close()

	if _, err := writer.WriteTo(f); err != nil {
		return fmt.Errorf("write %s: %w", outputFile, err)
	}

	if err := os.Rename(tmpFile, outputFile); err != nil {
		return fmt.Errorf("rename %s to %s: %w", tmpFile, outputFile, err)
	}

	return nil
}
