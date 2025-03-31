
install_home_bin_dir() {
    mkdir -p "$HOME/.ag/bin"
}
exists_home_bin_dir() {
    [ -d "$HOME/.ag/bin" ]
}
install_wrapper "home .ag/bin directory" install_home_bin_dir exists_home_bin_dir
