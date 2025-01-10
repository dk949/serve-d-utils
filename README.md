# serve-d-utils

Utilities to use custom requests and notifications for the
[serve-d](https://github.com/Pure-D/serve-d/) LSP.


## Quick start

```lua
-- Load the module and find the client
local serve_d = require("serve_d_utils").new()

-- Call a function on the client
local arch_type = serve_d:getArchType()
```

## Documentation

Most complete documentation is written inline in the
`lua/serve-d-utils/init.lua` file, but a vim help file is also provided.
