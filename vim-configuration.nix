with import <nixpkgs> {};

let 
  vim_configurable_py3 = vim_configurable.override {
    python = python36Full;
  };

in

  vim_configurable_py3.customize {
    name = "vim";
    vimrcConfig.customRC = ''
      syntax enable
      set number
      '';
}
