D:\iverilog\bin\iverilog -g2005-sv -Dsim -o tb -s tb tb.v
if %errorlevel% NEQ 0 goto :fail
D:\iverilog\bin\vvp tb
python3 log2frame.py
:fail
pause
