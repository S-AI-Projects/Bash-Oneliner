#!/usr/bin/env bats

STRICT_RE='^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$'

@test "accepts 192.168.1.10" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '192.168.1.10') else 1)"
  [ "$status" -eq 0 ]
}

@test "accepts 0.0.0.0" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '0.0.0.0') else 1)"
  [ "$status" -eq 0 ]
}

@test "accepts 127.0.0.1" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '127.0.0.1') else 1)"
  [ "$status" -eq 0 ]
}

@test "accepts 255.255.255.255" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '255.255.255.255') else 1)"
  [ "$status" -eq 0 ]
}

@test "accepts 8.8.8.8" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '8.8.8.8') else 1)"
  [ "$status" -eq 0 ]
}

@test "rejects 256.1.1.1" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '256.1.1.1') else 1)"
  [ "$status" -eq 1 ]
}

@test "rejects 999.999.999.999" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '999.999.999.999') else 1)"
  [ "$status" -eq 1 ]
}

@test "rejects 1.2.3.4.5" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '1.2.3.4.5') else 1)"
  [ "$status" -eq 1 ]
}

@test "rejects 192.168.1.256" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '192.168.1.256') else 1)"
  [ "$status" -eq 1 ]
}

@test "rejects alphabetic string" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', 'a.b.c.d') else 1)"
  [ "$status" -eq 1 ]
}

@test "rejects negative octet" {
  run python3 -c "import re, sys; sys.exit(0 if re.match(r'$STRICT_RE', '1.2.3.-1') else 1)"
  [ "$status" -eq 1 ]
}
