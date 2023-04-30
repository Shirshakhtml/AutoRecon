#!/bin/bash

# Get the target domain from the user
read -p "Enter the target domain (in the format of domain.com): " DOMAIN_NAME

# Check that the domain name is in the correct format
if [[ ! "$DOMAIN_NAME" =~ ^[a-z0-9]+(\.[a-z0-9]+)*\.[a-z]{2,}$ ]]; then
  echo "Error: Invalid domain name format. Please enter the domain name in the format of domain.com"
  exit 1
fi

# Define the target URL
TARGET_URL="http://$DOMAIN_NAME"

# Define the output directory
OUTPUT_DIR="output"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Perform subdomain discovery using subfinder
echo "Running subdomain discovery with subfinder..."
subfinder -d "$DOMAIN_NAME" -o "$OUTPUT_DIR/subdomains.txt"

# Check for live subdomains using httpx
echo "Checking for live subdomains using httpx..."
cat "$OUTPUT_DIR/subdomains.txt" | httpx -silent -status-code -o "$OUTPUT_DIR/live_subdomains.txt"

# Perform a basic scan using Nikto on live subdomains
echo "Running Nikto scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  nikto -h "$url" -output "$OUTPUT_DIR/nikto_$url.txt"
done

# Perform an Nmap scan to identify open ports and services on live subdomains
echo "Running Nmap scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  nmap -sV -p- "$url" -oN "$OUTPUT_DIR/nmap_$url.txt"
done

# Perform a directory and file enumeration using Dirb on live subdomains
echo "Running Dirb on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  dirb "$url" "$OUTPUT_DIR/dirb_$url.txt"
done

# Perform a SQL injection test using Sqlmap on live subdomains
echo "Running Sqlmap on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  sqlmap -u "$url" --batch --output-dir="$OUTPUT_DIR/sqlmap_$url"
done

# Perform a cross-site scripting (XSS) test using Xsser on live subdomains
echo "Running Xsser on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  xsser -u "$url" -o "$OUTPUT_DIR/xsser_$url.html"
done

# Perform a vulnerability scan using OWASP ZAP on live subdomains
echo "Running OWASP ZAP scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running OWASP ZAP scan on $url..."
  zap-cli --zap-path /usr/share/zaproxy/zap.sh --output "$OUTPUT_DIR/zap_$url.html" -t "$url"
done

# Perform active reconnaissance with ffuf on live subdomains
echo "Running active reconnaissance with ffuf on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running ffuf on $url..."
  ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u "$url/FUZZ"
done

# Perform passive reconnaissance with sublist3r on live subdomains
echo "Running passive reconnaissance with sublist3r on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running sublist3r on $url..."
  sublist3r -d "$url" -o "$OUTPUT_DIR/sublist3r_$url.txt"
done

# Find hidden or secret endpoints with ffuf on live subdomains
echo "Finding hidden or secret endpoints with ffuf on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Finding hidden or secret endpoints with ffuf on $url..."
  ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u "$url/FUZZ" -e .html,.php,.asp,.aspx,.jsp,.txt,.js,.xml,.json,.sql -fs 404
done
