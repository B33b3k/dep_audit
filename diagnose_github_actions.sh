#!/bin/bash

# 🔧 Diagnostic Script for GitHub Actions Repository Access Issue
# Run this script to check common causes of repository access failures

echo "🔍 GitHub Actions Repository Access Diagnostics"
echo "=============================================="
echo

# Check 1: Repository API Access
echo "📡 Testing GitHub API access..."
echo "Repository: B33b3k/dep_audit"
response=$(curl -s -w "\n%{http_code}" https://api.github.com/repos/B33b3k/dep_audit)
http_code=$(echo "$response" | tail -n1)
content=$(echo "$response" | head -n -1)

if [ "$http_code" = "200" ]; then
    echo "✅ Repository is accessible via GitHub API"
    visibility=$(echo "$content" | grep -o '"private":[^,]*' | cut -d':' -f2)
    if [ "$visibility" = "false" ]; then
        echo "✅ Repository is PUBLIC"
    else
        echo "⚠️  Repository is PRIVATE - this might cause Actions issues"
        echo "   Consider making it public for pub.dev publishing"
    fi
else
    echo "❌ Repository access failed (HTTP $http_code)"
    if [ "$http_code" = "404" ]; then
        echo "   This usually means:"
        echo "   - Repository is private and you don't have access"
        echo "   - Repository name/owner is incorrect"
        echo "   - Repository doesn't exist"
    fi
fi
echo

# Check 2: Git Remote Configuration
echo "🔗 Checking git remote configuration..."
remote_url=$(git remote get-url origin 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "✅ Git remote URL: $remote_url"
    if [[ "$remote_url" == *"B33b3k/dep_audit"* ]]; then
        echo "✅ Remote URL matches expected repository"
    else
        echo "⚠️  Remote URL doesn't match expected B33b3k/dep_audit"
    fi
else
    echo "❌ No git remote configured"
fi
echo

# Check 3: Recent Tags
echo "🏷️  Checking recent tags..."
recent_tags=$(git tag --sort=-version:refname | head -3)
if [ -n "$recent_tags" ]; then
    echo "✅ Recent tags found:"
    echo "$recent_tags" | while read -r tag; do
        echo "   📌 $tag"
    done
else
    echo "❌ No tags found"
fi
echo

# Check 4: GitHub Actions Workflow Files
echo "⚙️  Checking GitHub Actions workflows..."
if [ -f ".github/workflows/publish.yml" ]; then
    echo "✅ Publish workflow exists"
    
    # Check if uses dart-lang/setup-dart
    if grep -q "dart-lang/setup-dart" .github/workflows/publish.yml; then
        echo "✅ Uses official dart-lang/setup-dart workflow"
    else
        echo "⚠️  Not using official dart-lang/setup-dart workflow"
    fi
    
    # Check permissions
    if grep -q "contents: read" .github/workflows/publish.yml; then
        echo "✅ Has contents: read permission"
    else
        echo "⚠️  Missing contents: read permission"
    fi
else
    echo "❌ Publish workflow not found"
fi

if [ -f ".github/workflows/ci.yml" ]; then
    echo "✅ CI workflow exists"
else
    echo "⚠️  CI workflow not found"
fi
echo

# Summary and Recommendations
echo "📋 SUMMARY & RECOMMENDATIONS"
echo "=========================="
echo

if [ "$http_code" = "200" ] && [ "$visibility" = "false" ]; then
    echo "🎯 LIKELY CAUSE: Repository is PUBLIC and accessible"
    echo "   The issue might be:"
    echo "   1. GitHub Actions permissions not properly configured"
    echo "   2. Temporary GitHub API issues"
    echo "   3. pub.dev configuration mismatch"
    echo
    echo "🔧 NEXT STEPS:"
    echo "   1. Go to: https://github.com/B33b3k/dep_audit/settings/actions"
    echo "   2. Set 'Workflow permissions' to 'Read and write permissions'"
    echo "   3. Enable 'Allow GitHub Actions to create and approve pull requests'"
    echo "   4. Check pub.dev automated publishing configuration"
elif [ "$http_code" = "404" ]; then
    echo "🎯 LIKELY CAUSE: Repository access restricted"
    echo "   The repository might be private or have restricted access"
    echo
    echo "🔧 NEXT STEPS:"
    echo "   1. Make repository public (recommended for open source packages)"
    echo "   2. Or configure proper GitHub Actions permissions for private repos"
elif [ "$http_code" != "200" ]; then
    echo "🎯 LIKELY CAUSE: GitHub API or network issue"
    echo "   HTTP code: $http_code"
    echo
    echo "🔧 NEXT STEPS:"
    echo "   1. Check your internet connection"
    echo "   2. Try again later (might be temporary GitHub issue)"
    echo "   3. Verify repository exists and is spelled correctly"
else
    echo "🎯 Repository seems accessible - check GitHub Actions permissions"
fi

echo
echo "💡 For detailed troubleshooting, see: GITHUB_ACTIONS_TROUBLESHOOTING.md"