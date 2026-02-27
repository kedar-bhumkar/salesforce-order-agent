#!/bin/bash
# Deployment script for OrderServiceAgent

set -e

echo "🚀 OrderServiceAgent Deployment Script"
echo "======================================="
echo ""

# Check if sf CLI is installed
if ! command -v sf &> /dev/null; then
    echo "❌ Error: Salesforce CLI (sf) is not installed"
    echo "   Install from: https://developer.salesforce.com/tools/salesforcecli"
    exit 1
fi

# Get target org
if [ -z "$1" ]; then
    echo "📋 Available orgs:"
    sf org list
    echo ""
    read -p "Enter target org alias (or press Enter for default): " TARGET_ORG
    TARGET_ORG=${TARGET_ORG:-$(sf config get target-org --json | jq -r '.result[0].value')}
else
    TARGET_ORG=$1
fi

if [ -z "$TARGET_ORG" ]; then
    echo "❌ Error: No target org specified"
    exit 1
fi

echo ""
echo "📦 Target Org: $TARGET_ORG"
echo ""

# Validate connection
echo "🔍 Validating connection to org..."
if ! sf org display --target-org "$TARGET_ORG" &> /dev/null; then
    echo "❌ Error: Cannot connect to org '$TARGET_ORG'"
    echo "   Run: sf org login web --alias $TARGET_ORG"
    exit 1
fi
echo "✅ Connection validated"
echo ""

# Deploy Apex classes first
echo "📝 Step 1/3: Deploying Apex classes..."
sf project deploy start \
    --source-path force-app/main/default/classes \
    --target-org "$TARGET_ORG" \
    --wait 10

echo "✅ Apex classes deployed"
echo ""

# Run tests
echo "🧪 Step 2/3: Running Apex tests..."
sf apex run test \
    --class-names OrderServiceControllerTest \
    --target-org "$TARGET_ORG" \
    --wait 10 \
    --result-format human \
    --code-coverage

echo "✅ Tests passed"
echo ""

# Deploy Flows
echo "🔄 Step 3/3: Deploying Flows..."
sf project deploy start \
    --source-path force-app/main/default/flows \
    --target-org "$TARGET_ORG" \
    --wait 10

echo "✅ Flows deployed"
echo ""

echo "========================================="
echo "🎉 Deployment Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Configure Agent Script in Setup → Agentforce → Agents"
echo "2. Create Action Definitions for SearchOrderFlow and ProcessRefundFlow"
echo "3. Update default_agent_user in OrderServiceAgent.agent"
echo "4. Test the agent in Agent Builder Preview"
echo ""
echo "📖 See README.md for detailed configuration instructions"
