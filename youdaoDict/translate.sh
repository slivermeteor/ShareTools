#! /bin/bash

# 检查参数个数 - 如果小于1 提示使用方式
if [ $# -eq 0 ]; then
	printf "Please pass words what you want to query whatever chinese or english.\n"
	printf "Such as, tl help; tl get out; tl 中文\n"
	
	exit 1;
fi

# 如果查询的是词组或者句子，将传入的参数拼接到一个变量上
words="";
for i in $@; do
	words="$words%20$i";
done
#echo $words 测试

# 通过正则裁切网页 得到我们想要的解释部分 写入到文件，准备删除重复部分
curl -s "http://dict.youdao.com/w/eng/$words" | grep "<li>[^<].*[^>]<\/li>" | sed 's/<li>//g' | sed 's/<\/li>//g' | sed 's/^[ \t]*//g' > /tmp/result.html 

# 检查是否为空
if [ -s /tmp/result.html ]; then
	# 删除重复
	sort -n /tmp/result.html | awk '{if($0!=line)print; line=$0}';

else
	# 中->英
	curl -s "http://dict.youdao.com/w/eng/$words" | grep "<a class=\"search.js\" href=\"/w/[a-z]*/#keyfrom=E2Ctranslation\">" | sed 's/<\/a>//g' | sed 's/<.*>//g' | sed 's/^[ \t]*//g' > /tmp/result.html

	if [ -s /tmp/result.html ]; then
		cat /tmp/result.html
	else
		printf "Can't find any translation about your input.\n"
		printf "Please check out your input.:D\n"
	fi
fi

# 删除临时文件
rm -r /tmp/result.html

exit 0
