# Regular Expression Examples

Content

- Number
  - [Number](#Number)
  - [Integer](#Integer)
  - [Positive Integer](#Positive Integer)
  - [Float](#Float)
- String
  - Email
  - URL
  - Telephone Number
- Appendixes
- References

## Number

### Number

```
^([-]?[1-9][0-9]*|0)([.][0-9]+|)$
```

Test Cases

- "a" => false
- "0" => true
- "-0" => false
- "1", "12", "321" => true
- "-1", "-12", "-321" => true
- "01" => false
- "-01" => false
- "+1" => false
- "0.0" => false
- "-0.0" => false
- "0.", "1.", ".0", ".1", "1..2", "01.1" => false
- "1.0", "0.7", "0.0001", "-1.2"  => true
- "690.7" => true
- `-0.1`????

### Integer

```
^([-]?[1-9][0-9]*|0)$
```

Test Cases

- "a" => false
- "0" => true
- "-0" => false
- "1", "12", "321" => true
- "-1", "-12", "-321" => true
- "01" => false
- "-01" => false
- "+1" => false

### Positive Integer

```
^[1-9][0-9]*$
```

### Float

```
^([-]?[1-9][0-9]*|0)[.][0-9]+$
```

Test Cases

- "a" => false
- "0" => false
- "-0" => false
- "1", "12", "321" => false
- "-1", "-12", "-321" => false
- 0.0 => true
- -0.0 => false
- 0.1, 0.001 => true
- 1.1, 123.1, "-1.2" => true

## String

### Password

At least one letter, one number, and one special character, and at least 8 characters

```
^(?![a-zA-Z]+$)(?![A-Z0-9]+$)(?![A-Z\W_]+$)(?![a-z0-9]+$)(?![a-z\W_]+$)(?![0-9\W_]+$)[a-zA-Z0-9\W_]{8,}$
```

12 characters, at least one letter, one number

```
^(?=.*[a-zA-Z])(?=.*\d).{12}$
```

### Email

### URL

### Telephone Number

```
^1[3-9][0-9]{9}$
```



## Appendixes

Regular expressions online Tester

- [regular expressions 101](https://regex101.com/)

## References