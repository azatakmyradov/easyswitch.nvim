# EasySwitch

*THIS IS WORK IN PROGRESS*

# Install
```lua
{ -- Lazy
    "azatakmyradov/easyswitch.nvim",
    dependencies = {
        "MunifTanjim/nui.nvim"
    },
},
```

# Usage

## Multiple plugins
You can wrap an object with `new` method from plugin:
```lua
return require('easyswitch').new({
    { 'github/copilot.vim', },
    { 'stevearc/conform.nvim', }
})

-- OR --

return require('easyswitch').new({
    'github/copilot.vim',
})
```

## Single plugin
1. Add *cond* option to lazy plugins that you want to control. Ex:
```lua
{
    -- GitHub Copilot
    'github/copilot.vim',
    cond = require("easyswitch").is_active("copilot.vim"),
}
```

2. Then you can enable/disable that plugin using this command
```lua
:lua require('easyswith').toggle()
```

# Keymaps

## Normal mode:
- `a` - to enable plugin
- `b` - to disable plugin
