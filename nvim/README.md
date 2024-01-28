## pickers

```java
<space>f    files
<space>b    buffers
<space>/    grep in workspace

<space>s    document symbols
<space>S    workspace symbols

<space>d    current diagnostics
<space>D    workspace diagnotics

<space>w    enter window mode
```

## lsp

```java
gd          goto definition
gD          goto declaration
gy          goto type definition
gi          goto implemenation
gr          goto references

<space>a    code actions
<space>r    rename
<space>e    show error
<space>k    show doc
<ctrl>k     show signature
```

## comment opertor

```java
gc{noun}    toggle line comment
gb{noun}    toggle block comment

gcc         toggle line comment to current line
gcb         toggle block comment to current line

gco         insert comment next line
gcA         insert comment end of line
gcO         insert comment prev line
```

## surround operator

```java
sa{noun}{addition}          surround with {addition}

sd{deletion}                delete surrounding {deletion} 
sdb                         delete  surrounding char

sr{deletion}{addition}      replace surrounding {deletion} with {addition}
srb{addition}               replace surrounding char with {addition}
```

## surround textobject

```java
ys{motion}{char}        surround by {char}
cs{char}{replacement}   replace surrouding {char} by {replacement}
ds{char}                delete surrounding {char}

use `q` for {char} to find surrounding char automatically
```

## move lines

```java
<alt>{h/j/k/l}  move current/selected line(s)
```
