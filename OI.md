# OI OS Integration Guide for OI-Figma-Context-MCP

This guide provides complete instructions for AI agents to install, configure, and use the OI-Figma-Context-MCP server in OI OS (Brain Trust 4).

## 🚀 Installation

### Prerequisites

| Requirement | Version        |
| ----------- | -------------- |
| **Node.js** | 18.x or higher |
| **npm**     | Latest         |
| **Git**     | Any            |
| **Figma API Key** | Required (Personal Access Token) |

### Getting a Figma API Key

1. Go to [Figma Account Settings](https://www.figma.com/settings)
2. Navigate to **Personal Access Tokens**
3. Click **Create new token**
4. Give it a name (e.g., "OI OS MCP Server")
5. Copy the token (you'll only see it once)

**Instructions:** https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens

### Installation Steps

1. **Clone the repository:**
   ```bash
   git clone https://github.com/OI-OS/OI-Figma-Context-MCP.git
   ```

2. **Navigate to the server directory:**
   ```bash
   cd MCP-servers/OI-Figma-Context-MCP
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Build the project:**
   ```bash
   npm run build
   ```

5. **Connect the server to OI OS:**
   ```bash
   cd ../../ # Go back to the OI OS root directory
   ./brain-trust4 connect OI-Figma-Context-MCP node -- "$(pwd)/MCP-servers/OI-Figma-Context-MCP/dist/bin.js" --stdio --figma-api-key=YOUR_FIGMA_API_KEY
   ```

   **Or set environment variable:**
   ```bash
   export FIGMA_API_KEY=YOUR_FIGMA_API_KEY
   ./brain-trust4 connect OI-Figma-Context-MCP node -- "$(pwd)/MCP-servers/OI-Figma-Context-MCP/dist/bin.js" --stdio
   ```

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the server directory (optional):

```bash
cd MCP-servers/OI-Figma-Context-MCP
echo "FIGMA_API_KEY=YOUR_FIGMA_API_KEY" > .env
```

**Or set globally:**
```bash
export FIGMA_API_KEY=YOUR_FIGMA_API_KEY
```

### Authentication Options

The server supports two authentication methods:

1. **Personal Access Token (Recommended)**
   - Set via `--figma-api-key` CLI argument
   - Or via `FIGMA_API_KEY` environment variable

2. **OAuth Bearer Token**
   - Set via `--figma-oauth-token` CLI argument
   - Or via `FIGMA_OAUTH_TOKEN` environment variable

## 📋 Creating Intent Mappings

Intent mappings connect natural language keywords to specific MCP server tools.

**SQL to create intent mappings:**

```sql
BEGIN TRANSACTION;

-- Intent mappings for OI-Figma-Context-MCP
INSERT OR REPLACE INTO intent_mappings (keyword, server_name, tool_name, priority) VALUES
('get figma data', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('fetch figma data', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('get figma design', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('fetch figma design', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('get figma file', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('fetch figma file', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('figma data', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('figma design', 'OI-Figma-Context-MCP', 'get_figma_data', 10),
('download figma images', 'OI-Figma-Context-MCP', 'download_figma_images', 10),
('fetch figma images', 'OI-Figma-Context-MCP', 'download_figma_images', 10),
('get figma images', 'OI-Figma-Context-MCP', 'download_figma_images', 10),
('download images from figma', 'OI-Figma-Context-MCP', 'download_figma_images', 10);

COMMIT;
```

## 📝 Creating Parameter Rules

Parameter rules define which fields are required and how to extract them from natural language queries.

**SQL to create parameter rules:**

```sql
BEGIN TRANSACTION;

-- Parameter rules for OI-Figma-Context-MCP
INSERT OR REPLACE INTO parameter_rules (server_name, tool_name, tool_signature, required_fields, field_generators, patterns) VALUES
('OI-Figma-Context-MCP', 'get_figma_data', 'OI-Figma-Context-MCP::get_figma_data', '["fileKey"]',
 '{"fileKey": {"FromQuery": "OI-Figma-Context-MCP::get_figma_data.fileKey"}, "nodeId": {"FromQuery": "OI-Figma-Context-MCP::get_figma_data.nodeId"}, "depth": {"FromQuery": "OI-Figma-Context-MCP::get_figma_data.depth"}}', '[]'),
('OI-Figma-Context-MCP', 'download_figma_images', 'OI-Figma-Context-MCP::download_figma_images', '["fileKey", "nodes", "localPath"]',
 '{"fileKey": {"FromQuery": "OI-Figma-Context-MCP::download_figma_images.fileKey"}, "nodes": {"FromQuery": "OI-Figma-Context-MCP::download_figma_images.nodes"}, "localPath": {"FromQuery": "OI-Figma-Context-MCP::download_figma_images.localPath"}, "pngScale": {"FromQuery": "OI-Figma-Context-MCP::download_figma_images.pngScale"}}', '[]');

COMMIT;
```

## 🔍 Parameter Extractors

Add these patterns to `parameter_extractors.toml.default`:

```toml
# ============================================================================
# OI-Figma-Context-MCP Parameter Extractors
# ============================================================================

# get_figma_data
"OI-Figma-Context-MCP::get_figma_data.fileKey" = "regex:(?:file[\\s_-]?key|file[\\s_-]?id|figma[\\s_-]?file)[\\s:]+([a-zA-Z0-9]+)|figma\\.com/(?:file|design)/([a-zA-Z0-9]+)"
"OI-Figma-Context-MCP::get_figma_data.nodeId" = "regex:(?:node[\\s_-]?id|node)[\\s:]+([I]?\\d+[:|-]\\d+(?:;\\d+[:|-]\\d+)*)|node-id=([I]?\\d+[:|-]\\d+(?:;\\d+[:|-]\\d+)*)"
"OI-Figma-Context-MCP::get_figma_data.depth" = "regex:(?:depth|levels?)[\\s:]+(\\d+)"

# download_figma_images
"OI-Figma-Context-MCP::download_figma_images.fileKey" = "regex:(?:file[\\s_-]?key|file[\\s_-]?id|figma[\\s_-]?file)[\\s:]+([a-zA-Z0-9]+)|figma\\.com/(?:file|design)/([a-zA-Z0-9]+)"
"OI-Figma-Context-MCP::download_figma_images.localPath" = "regex:(?:path|local[\\s_-]?path|directory|dir)[\\s:]+([^\\s]+)"
"OI-Figma-Context-MCP::download_figma_images.pngScale" = "regex:(?:scale|png[\\s_-]?scale)[\\s:]+(\\d+)"
```

## 🛠️ Available Tools

### 1. `get_figma_data`

**Description:** Get comprehensive Figma file data including layout, content, visuals, and component information. Returns simplified design data optimized for AI code generation.

**Parameters:**
- `fileKey` (required): The key of the Figma file (alphanumeric, found in URL like `figma.com/file/<fileKey>/...`)
- `nodeId` (optional): The ID of the node to fetch (format: `1234:5678` or `I5666:180910;1:10515;1:10336` for multiple nodes)
- `depth` (optional): How many levels deep to traverse the node tree (only use if explicitly requested)

**Example Direct Call:**
```bash
./brain-trust4 call OI-Figma-Context-MCP get_figma_data '{
  "fileKey": "abc123xyz",
  "nodeId": "1234:5678"
}'
```

**Example Natural Language:**
```bash
./oi "get figma data from file abc123xyz"
./oi "fetch figma design from https://figma.com/file/abc123xyz/My-Design"
./oi "get figma data for node 1234:5678 in file abc123xyz"
```

### 2. `download_figma_images`

**Description:** Download SVG and PNG images used in a Figma file based on the IDs of image or icon nodes. Supports cropping, scaling, and CSS variable generation.

**Parameters:**
- `fileKey` (required): The key of the Figma file containing the images
- `nodes` (required): Array of node objects with:
  - `nodeId` (required): The ID of the Figma image node (format: `1234:5678`)
  - `fileName` (required): Local filename including extension (`.png` or `.svg`)
  - `imageRef` (optional): Required if node has an imageRef fill
  - `needsCropping` (optional): Whether image needs cropping
  - `cropTransform` (optional): Figma transform matrix for cropping
  - `filenameSuffix` (optional): Suffix for unique cropped images
- `localPath` (required): Absolute path to directory where images are stored
- `pngScale` (optional): Export scale for PNG images (default: 2)

**Example Direct Call:**
```bash
./brain-trust4 call OI-Figma-Context-MCP download_figma_images '{
  "fileKey": "abc123xyz",
  "nodes": [
    {
      "nodeId": "1234:5678",
      "fileName": "icon.svg"
    }
  ],
  "localPath": "/path/to/project/images"
}'
```

**Example Natural Language:**
```bash
./oi "download figma images from file abc123xyz to /path/to/images"
```

**Note:** The `download_figma_images` tool requires complex array parameters that are difficult to extract from natural language. Consider using direct calls for this tool.

## 📚 Usage Examples

### Example 1: Get Figma Design Data

**Query:**
```bash
./oi "get figma data from https://figma.com/file/abc123xyz/My-Design"
```

**What happens:**
1. Intent mapping matches "get figma data" → `get_figma_data`
2. Parameter extraction extracts `fileKey: "abc123xyz"` from URL
3. Tool fetches design data from Figma API
4. Returns simplified layout, content, visuals, and component information

### Example 2: Get Specific Node

**Query:**
```bash
./oi "get figma data for node 1234:5678 in file abc123xyz"
```

**What happens:**
1. Intent mapping matches "get figma data" → `get_figma_data`
2. Parameter extraction extracts:
   - `fileKey: "abc123xyz"`
   - `nodeId: "1234:5678"`
3. Tool fetches specific node data
4. Returns node-specific design information

### Example 3: Download Images (Direct Call Recommended)

**Direct Call:**
```bash
./brain-trust4 call OI-Figma-Context-MCP download_figma_images '{
  "fileKey": "abc123xyz",
  "nodes": [
    {
      "nodeId": "1234:5678",
      "fileName": "icon.svg"
    },
    {
      "nodeId": "5678:9012",
      "fileName": "logo.png",
      "imageRef": "abc123"
    }
  ],
  "localPath": "/Users/me/project/images",
  "pngScale": 2
}'
```

## 🔍 How It Works

### Design Data Simplification

The server simplifies Figma API responses to provide only the most relevant layout and styling information:

- **Layout information** - Positioning, sizing, constraints
- **Content** - Text content and styling
- **Visuals** - Colors, gradients, effects
- **Components** - Component instances and variants
- **Global variables** - Design tokens, styles, variables

This simplification helps AI agents generate more accurate code by reducing noise and focusing on essential design information.

### Output Format

- **Default:** YAML format (human-readable, optimized for AI)
- **Optional:** JSON format (set `--json` flag or `OUTPUT_FORMAT=json`)

## 🐛 Troubleshooting

### Server Closes Connection

**Error:** "Server closed connection" or "Initialization failed"

**Solution:** The server requires a Figma API key. Make sure to:
1. Provide `--figma-api-key` argument, OR
2. Set `FIGMA_API_KEY` environment variable

```bash
# Option 1: CLI argument
./brain-trust4 connect OI-Figma-Context-MCP node -- "$(pwd)/MCP-servers/OI-Figma-Context-MCP/dist/bin.js" --stdio --figma-api-key=YOUR_KEY

# Option 2: Environment variable
export FIGMA_API_KEY=YOUR_KEY
./brain-trust4 connect OI-Figma-Context-MCP node -- "$(pwd)/MCP-servers/OI-Figma-Context-MCP/dist/bin.js" --stdio
```

### Invalid File Key

**Error:** "File key must be alphanumeric"

**Solution:** Extract the file key from the Figma URL:
- URL: `https://figma.com/file/abc123xyz/My-Design`
- File key: `abc123xyz`

### Invalid Node ID Format

**Error:** "Node ID must be like '1234:5678'"

**Solution:** Node IDs must be in format `1234:5678` or `I5666:180910;1:10515;1:10336` for multiple nodes. Extract from Figma URL parameter `node-id=...`.

### Authentication Failed

**Error:** "401 Unauthorized" or authentication errors

**Solution:**
1. Verify your Figma API key is correct
2. Check that the token hasn't expired
3. Ensure the token has necessary permissions
4. Try creating a new token

### Build Fails

**Error:** TypeScript compilation errors

**Solution:**
```bash
# Clean and rebuild
cd MCP-servers/OI-Figma-Context-MCP
rm -rf dist node_modules
npm install
npm run build
```

## 📖 Additional Resources

- **GitHub Repository:** https://github.com/OI-OS/OI-Figma-Context-MCP
- **Original Repository:** https://github.com/GLips/Figma-Context-MCP
- **Framelink Website:** https://www.framelink.ai
- **Figma API Documentation:** https://www.figma.com/developers/api
- **Figma Personal Access Tokens:** https://help.figma.com/hc/en-us/articles/8085703771159-Manage-personal-access-tokens
- **MCP Protocol:** https://modelcontextprotocol.org

## ✅ Verification

After installation, verify the server is working:

```bash
# List tools
./brain-trust4 tools OI-Figma-Context-MCP

# Test with a Figma file (replace with your file key)
./oi "get figma data from file YOUR_FILE_KEY"
```

## 🎯 Summary

The OI-Figma-Context-MCP server provides two powerful tools:
1. **Get Figma Data**: Fetch design information optimized for AI code generation
2. **Download Figma Images**: Download SVG and PNG assets from Figma files

Both tools work with natural language queries (though `download_figma_images` is better suited for direct calls due to complex parameters). The server simplifies Figma API responses to provide only the most relevant information for accurate code generation.

