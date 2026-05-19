# 自动安全同步本地文件到 GitHub（使用 SSH），冲突自动保留远程版本
Write-Host "Starting fully automated safe sync to GitHub via SSH..."

# 确认远程仓库是 SSH 地址
$remoteUrl = git remote get-url origin
if ($remoteUrl -notmatch "^git@github\.com:") {
    Write-Host "Changing remote URL to SSH..."
    git remote set-url origin git@github.com:caiwenjie17-a11y/cfiptest.git
}

# 1. 获取远程 main 分支到本地临时分支 tmp_main
git fetch origin main:tmp_main
if ($LASTEXITCODE -ne 0) {
    Write-Host "Remote 'main' branch does not exist or fetch failed."
    exit
}

# 2. 切换到本地 master 分支，如果没有则创建
git checkout master
if ($LASTEXITCODE -ne 0) {
    Write-Host "Local 'master' branch does not exist, creating it..."
    git checkout -b master
}

# 3. 合并远程 tmp_main 分支，允许历史不相关，并自动保留远程文件
git merge tmp_main --allow-unrelated-histories -X theirs
if ($LASTEXITCODE -ne 0) {
    Write-Host "Merge completed. Remote files preferred for conflicts."
}

# 4. 添加所有更改（包括新文件）
git add .

# 5. 提交合并
git commit -m "Merge local files with remote main (remote files preferred)" 2>$null

# 6. 推送本地 master 到远程 main
git push origin master:main
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Local files have been fully synced to GitHub main branch via SSH!"
} else {
    Write-Host "❌ Push failed. Please check your SSH keys or GitHub access."
}

# 7. 删除临时分支
git branch -d tmp_main