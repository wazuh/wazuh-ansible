# 1. Ejecutar bump normal (distinto stage)
echo "$ sed -i 's/"stage": "alpha0"/"stage": "rc1"/' VERSION.json"
sed -i 's/"stage": "alpha0"/"stage": "rc1"/' VERSION.json

echo "$ cat VERSION.json"
cat VERSION.json

# 2. Ejecutar bumper con los mismos valores + --tag true
echo "$ bash tools/repository_bumper.sh --version 4.14.5 --stage rc1"
bash tools/repository_bumper.sh --version 4.14.5 --stage rc1

# 3. Evidencia
echo "$ cat tools/repository_bumper_*.log"
cat tools/repository_bumper_*.log

echo "$ git status"
git status

# 4. Cleanup
git checkout -- .
rm -f tools/repository_bumper_*.log
