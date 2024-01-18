return {
    ["rust-analyzer"] = {
        check = { command = "clippy" },
        cargo = { features = "all" },
    }
}
