
# Tests for `Resolve-PowershellTask3A.ps1`

---

## 0) Quick sanity check — minimal required invocation

```powershell
# Required: -RequiredParameter and -EndavaPurposeAndValues
.\Resolve-PowershellTask3A.ps1 -RequiredParameter "req" -EndavaPurposeAndValues Smart
````

**Expect:**

* `RequiredParameter : req`
* `EndavaPurposeAndValues : Smart`
* `MessageWithDefaultValue : I love DevOps!` (default in effect)
* `DateFrom` printed (7 days ago)


---

## 1) `ParameterWithoutType` (accepts any type)

```powershell
# string
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -ParameterWithoutType "hello"

# boolean
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -ParameterWithoutType $true

# number
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -ParameterWithoutType 123

# array (mixed types)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -ParameterWithoutType ("a", 2, $false, @{k=1})

# hashtable
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -ParameterWithoutType @{ a = 1; b = "x" }
```

**Expect:** `ParameterWithoutType` shows the value(s) as passed (any type accepted).

---

## 2) `ParameterWithType` (string if provided)

```powershell
# valid (string)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Adaptable -ParameterWithType "hello"

# edge case: numeric literal is auto-converted to string by PowerShell
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Adaptable -ParameterWithType 123
```

**Expect:** Shows as string in output (PowerShell converts 123 → "123").

---

## 3) `RequiredParameter` (must be supplied)

```powershell
# FAIL (omit required): should throw a "Missing an argument for parameter" error
.\Resolve-PowershellTask3A.ps1 -EndavaPurposeAndValues Trusted
```

```powershell
# PASS
.\Resolve-PowershellTask3A.ps1 -RequiredParameter "I am required" -EndavaPurposeAndValues Trusted
```

---

## 4) `MessageWithDefaultValue` (default: `I love DevOps!`)

```powershell
# use default
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart

# override default
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -MessageWithDefaultValue "Keep learning!"
```

**Expect:**

* Default case prints `"I love DevOps!"`.
* Override prints your custom string.

---

## 5) `Message5to15` (length between 5 and 15)

```powershell
# FAIL (too short)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Thoughtful -Message5to15 "abcd"

# FAIL (too long)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Thoughtful -Message5to15 "1234567890123456"

# PASS (within 5..15)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Thoughtful -Message5to15 "Push hard!"
```

**Expect:**

* Failures throw a ValidateLength error.
* Passing one prints the value.

---

## 6) `MessageWithSoD` (must contain "SoD", case-insensitive)

```powershell
# FAIL (no SoD substring)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -MessageWithSoD "Hello world"

# PASS (mixed case)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open -MessageWithSoD "Do you love sOd?"
```

**Expect:**

* First command throws a ValidatePattern error.
* Second command passes and prints the value.

---

## 7) `DateFrom` (default: 7 days ago) and `DateTo` (must be ≥ DateFrom)

```powershell
# PASS: only DateTo provided, DateFrom uses default (7 days ago)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -DateTo (Get-Date)

# PASS: custom DateFrom/DateTo (valid order)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -DateFrom "2025-08-01" -DateTo "2025-09-25"

# FAIL: DateTo earlier than DateFrom (should throw from ValidateScript)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -DateFrom "2025-09-25" -DateTo "2025-08-01"
```

**Expect:**

* First two pass; third throws: `DateTo (...) must not be earlier than DateFrom (...)`.

> Tip: ISO dates (`YYYY-MM-DD`)
---

## 8) `EndavaPurposeAndValues` (ValidateSet)

```powershell
# PASS (each of these)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Thoughtful
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Adaptable
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Trusted

# FAIL (not in set)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues "Clever"
```

**Expect:**

* The last command throws a ValidateSet error listing allowed values.

---

## 9) `OutputPath` (must be an existing folder)

```powershell
# FAIL (nonexistent path)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -OutputPath "C:\Nope\Missing"

# PASS (existing path - adjust to a known folder on your machine)
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -OutputPath "C:\Windows"
```

**Expect:**

* First command throws: `OutputPath (...) must be an existing folder.`
* Second command prints the path.

---

## 10) `MessageFromPipeline` (pipeline & property-name binding)

> Your script declares:
>
> ```powershell
> [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
> [string] $MessageFromPipeline
> ```

### A) Direct pipeline value (ValueFromPipeline)

```powershell
"Hello direct pipeline" | .\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open
```

**Expect:** `MessageFromPipeline : Hello direct pipeline`

### B) Property-name binding (ValueFromPipelineByPropertyName)

```powershell
[PSCustomObject]@{ MessageFromPipeline = "Hello via property!" } |
  .\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open
```

**Expect:** `MessageFromPipeline : Hello via property!`

### C) Convert any input to a property named like the parameter

```powershell
"One","Two","Three" |
  Select-Object @{n='MessageFromPipeline';e={$_}} |
  .\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Open
```

**Expect:** For each piped item, script runs once and prints the respective value.

---

## 11) Full happy-path example (all common params)

```powershell
.\Resolve-PowershellTask3A.ps1 `
  -RequiredParameter "Here is School Of DevOps!" `
  -EndavaPurposeAndValues Adaptable `
  -ParameterWithoutType $true `
  -ParameterWithType "Hello" `
  -MessageWithDefaultValue "Custom Message" `
  -Message5to15 "Push hard!" `
  -MessageWithSoD "Do you love SoD?" `
  -DateFrom "2025-08-01" `
  -DateTo "2025-09-25" `
  -OutputPath "C:\Endava\EndevLocal\Temp" `
  -MessageFromPipeline "Caught it!"
```

**Expect:** All values printed, validations pass.

---

## 12) Quick error-handling smoke tests

```powershell
# Missing required parameter
.\Resolve-PowershellTask3A.ps1 -EndavaPurposeAndValues Smart

# Wrong ValidateSet
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues "Wrong"

# Message5to15 too long
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -Message5to15 "this is way too long"

# MessageWithSoD missing 'SoD'
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -MessageWithSoD "no keyword here"

# OutputPath not a folder (point to a file to see it fail)
$someFile = "$env:TEMP\dummy.txt"; Set-Content -Path $someFile -Value "x"
.\Resolve-PowershellTask3A.ps1 -RequiredParameter 1 -EndavaPurposeAndValues Smart -OutputPath $someFile
```

**Expect:** Each throws with the corresponding validation message.

---
