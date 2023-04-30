#!/bin/bash


read -p "Enter the target domain (in the format of domain.com): " DOMAIN_NAME


if [[ ! "$DOMAIN_NAME" =~ ^[a-z0-9]+(\.[a-z0-9]+)*\.[a-z]{2,}$ ]]; then
  echo "Error: Invalid domain name format. Please enter the domain name in the format of domain.com"
  exit 1
fi


TARGET_URL="http://$DOMAIN_NAME"


OUTPUT_DIR="output"

mkdir -p "$OUTPUT_DIR"

echo "Running subdomain discovery with subfinder..."
subfinder -d "$DOMAIN_NAME" -o "$OUTPUT_DIR/subdomains.txt"


echo "Checking for live subdomains using httpx..."
cat "$OUTPUT_DIR/subdomains.txt" | httpx -silent -status-code -o "$OUTPUT_DIR/live_subdomains.txt"


echo "Running Nikto scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  nikto -h "$url" -output "$OUTPUT_DIR/nikto_$url.txt"
done


echo "Running Nmap scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  nmap -sV -p- "$url" -oN "$OUTPUT_DIR/nmap_$url.txt"
done


echo "Running Dirb on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  dirb "$url" "$OUTPUT_DIR/dirb_$url.txt"
done


echo "Running Sqlmap on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  sqlmap -u "$url" --batch --output-dir="$OUTPUT_DIR/sqlmap_$url"
done


echo "Running Xsser on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  xsser -u "$url" -o "$OUTPUT_DIR/xsser_$url.html"
done


echo "Running OWASP ZAP scan on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running OWASP ZAP scan on $url..."
  zap-cli --zap-path /usr/share/zaproxy/zap.sh --output "$OUTPUT_DIR/zap_$url.html" -t "$url"
done


echo "Running active reconnaissance with ffuf on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running ffuf on $url..."
  ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u "$url/FUZZ"
done


echo "Running passive reconnaissance with sublist3r on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Running sublist3r on $url..."
  sublist3r -d "$url" -o "$OUTPUT_DIR/sublist3r_$url.txt"
done


echo "Finding hidden or secret endpoints with ffuf on live subdomains..."
cat "$OUTPUT_DIR/live_subdomains.txt" | while read url; do
  echo "Finding hidden or secret endpoints with ffuf on $url..."
  ffuf -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt -u "$url/FUZZ" -e .html,.php,.asp,.aspx,.jsp,.txt,.js,.xml,.json,.sql -fs 404
done
