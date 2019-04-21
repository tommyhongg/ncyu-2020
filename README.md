Example 1:

1. 建立新的資料夾並切換至新資料夾

2. 執行以下指令

```
git init
echo "Example 1" > ex1.txt
```

3. 將ex1.txt加入git local repository並commit

4. 在新資料夾下執行以下指令

```
bash <(curl -s https://raw.githubusercontent.com/jrjang/ncyu-2020/ex1/scripts/ex1-test.sh) GITHUB_ACCOUNT GITHUB_PROJECT
```

GITHUB_ACCOUNT: github帳號

GITHUB_PROJECT: github repository名稱 (之後的example皆可以用同樣名稱, 建議使用ncyu-2020)
