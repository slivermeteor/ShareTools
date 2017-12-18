# 检查参数个数 - 如果小于 1 提示使用方法
if ($args.Count -lt 1)
{
    Write-Host "Please pass words what you want to query whatever chinese or english."
    $Message = "Such as, tl help; tl get out; tl [Chinese]" 
    Write-Host $Message
    Exit 1;
}



# 得到脚本所在目录
$work_path = Split-Path -Parent $MyInvocation.MyCommand.Definition;
# 测试工作目录
# Write-Host "$Work_path"

# 判断 查询记录 / 清空记录
switch -Regex ($args[0])
{
    "-[h|histroy]" 
    {
        # 测试 switch 分流
        # Write-Host "-h | -histroy"

        # 判断记录文件是否已经存在
        if (Test-Path "$work_path/record")
        {
            # 存在 - 输出记录
            Get-Content -Path "$work_path/record"
        }
        else 
        {
            # 不存在
            Write-Host "No record";
        }

        exit 0;
    }
    "-[c|clear]"
    {
        # 清空记录
        Remove-Item "$work_path/record";
        exit 0;
    }
}

$words = $($args[0]);
# 如果是查询词组,合并单词到一个变量上
if ($args.Count -gt 1)
{
    For ($i = 0; $i -lt $args.Count; $i++)
    {
        $words = "$words%20$($args[$i])"
    }
}
# 测试合并结果
#Write-Host "$words"

# 英 -> 中
# 向网页请求得到网页源码,将结果写入文件.来准备接下来的行处理.
try 
{
    Invoke-WebRequest -UseBasicParsing -Uri "http://dict.youdao.com/w/eng/$words" -OutFile "$work_path/temp.html"   
}
catch 
{
    # 断网异常捕获
    Write-Host "Can't link to the internet.Please check your internet."
    exit 1;
}

# 读取文件 - 注意编码格式 以防中文乱码
$Content = Get-Content "$work_path/temp.html" -Encoding UTF8
# 遍历每一行 进行正则匹配
foreach ($Line in $Content)
{
    # 测试遍历行
    # Write-Host $Line                                    
    #                                                       去除多余标签                                       去掉行首行尾空格           
    $Line | Select-String -Pattern "<li>[^<].*[^>]<\/li>" | %{$_ -replace "<li>"} | %{$_ -replace "</li>"} | %{$_.Trim()} | Out-File -Append "$work_path/result.html" -Encoding UTF8
}
# 使用 C# Hashset 类进行去重处理
[System.Collections.Generic.HashSet[string]]$Lines=Get-Content -Path "$work_path/result.html" -ReadCount 0 -Encoding UTF8

# 判断 result.html 是否为空 来确定是否转向 中 -> 英
if ($Lines.Length -gt 0)
{
    # 长度大于 0 - 得到了翻译结果
    foreach ($data in $Lines)
    {
        Write-Host $data
    }

    # 确定是 英 -> 中,记录查询结果
    #         Get-Date 按照指定个数输出时间          将词组里的 %20 转换为空格
    "$words $(Get-Date -Format y/m/d-H:M:s)" | %{$_ -replace "%20", " "} | %{$_.Trim()} | Out-File -Append "$work_path/record" -Encoding UTF8
}
else
{
    # 转向 中 -> 英
    Invoke-WebRequest -UseBasicParsing -Uri "http://dict.youdao.com/w/eng/$words" -OutFile "$work_path/temp.html"
    $Content = Get-Content "$work_path/temp.html" -Encoding UTF8

    # 遍历每一行行 进行正则匹配
    foreach ($Line in $Content)
    {
        # 注意 powershell 在字符串中忽略特殊字符使用的 ` 而非 Unix shell 中的 \
        $Line | Select-String -Pattern "<a class=`"search-js`" href=`"/w/.*/`#keyfrom=E2Ctranslation`">" | %{$_ -replace "<\/a>"} | %{$_ -replace "<.*>"} | %{$_.Trim()} | Out-File -Append "$work_path/result.html"
    }
    
    # 其实在上面 过滤即可完成输出任务,但是考虑到删除临时文件统一性,还是选择了文件读取. --- 待优化 ?
    $Lines=Get-Content -Path "$work_path/result.html" -Encoding UTF8
    # 如果 英 -> 中,还是无内容.提醒修改输入
    if ($Lines.Length -eq 0)
    {
        Write-Host "Can't find any translation about your input."
        Write-Host "Please check out your input. :D"
        # 代码在这里退出,统一在下方删除临时文件
    }
    else 
    {
        foreach ($data in $Lines)
        {
            Write-Host $data
        }

        # 记录结果
        "$(Get-Date -Format y/m/d-H:M:s) $words" | %{$_ -replace "%20", " "} | %{$_.Trim()} | Out-File -Append "$work_path/record" -Encoding UTF8
    }
}

# 删除临时文件
Remove-Item "$work_path/temp.html"
Remove-Item "$work_path/result.html"

exit 0;

# 如何在 powershell 下给一个命令设置一个永久的别名
# 其实非常类似 Unix-shell 需要写入 bashrc 文件来修改,powershell 也需要修改对应的配置文件.
# 只不过这个文件默认并不存在,需要首先手动创建.
# New-Item -Type file -Force $profile (在哪里运行都可以)
# 然后系统会提示你创建的配置文件路径
# 编辑它,将你的 Set-Alias 或 New-Alias 指令写在里面即可 
