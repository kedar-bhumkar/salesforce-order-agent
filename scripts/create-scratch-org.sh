#!/bin/bash
# Create scratch org for OrderServiceAgent development

set -e

echo "🏗️  OrderServiceAgent - Scratch Org Creation"
echo "==========================================="
echo ""

# Check if sf CLI is installed
if ! command -v sf &> /dev/null; then
    echo "❌ Error: Salesforce CLI (sf) is not installed"
    exit 1
fi

# Get org alias
read -p "Enter alias for scratch org (default: order-agent-scratch): " ORG_ALIAS
ORG_ALIAS=${ORG_ALIAS:-order-agent-scratch}

# Get duration
read -p "Enter duration in days (1-30, default: 7): " DURATION
DURATION=${DURATION:-7}

echo ""
echo "📋 Creating scratch org with:"
echo "   Alias: $ORG_ALIAS"
echo "   Duration: $DURATION days"
echo ""

# Create scratch org
echo "🔨 Creating scratch org..."
sf org create scratch \
    --definition-file config/project-scratch-def.json \
    --alias "$ORG_ALIAS" \
    --duration-days "$DURATION" \
    --set-default \
    --no-namespace

echo "✅ Scratch org created"
echo ""

# Deploy code
echo "📦 Deploying code to scratch org..."
./scripts/deploy.sh "$ORG_ALIAS"

echo ""
echo "==========================================="
echo "🎉 Scratch Org Ready!"
echo ""
echo "📋 Org Details:"
sf org display --target-org "$ORG_ALIAS"
echo ""
echo "🌐 Open org:"
echo "   sf org open --target-org $ORG_ALIAS"
echo ""
echo "⏰ Expires in $DURATION days"
