call "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\vcvars32.bat"
cd "C:\Users\vagrant\Documents\Jenkins"
start /b cmd /c "java -jar slave.jar -jnlpUrl http://aa00:8080/computer/win7-32/slave-agent.jnlp"
