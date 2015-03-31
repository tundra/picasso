call "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"

cd "C:\Users\vagrant\Jenkins"

start /b cmd /c "java -jar slave.jar -jnlpUrl http://ci.t.undra.org/computer/<label>/slave-agent.jnlp -secret <secret>"
