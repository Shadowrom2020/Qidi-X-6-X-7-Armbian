function extension_finish_config__install_kernel_headers_for_aic8800_dkms() {

	if [[ "${KERNEL_HAS_WORKING_HEADERS}" != "yes" ]]; then
		display_alert "Kernel version has no working headers package" "skipping aic8800 dkms for kernel v${KERNEL_MAJOR_MINOR}" "warn"
		return 0
	fi
	declare -g INSTALL_HEADERS="yes"
	display_alert "Forcing INSTALL_HEADERS=yes; for use with aic8800 dkms" "${EXTENSION}" "debug"
}

function post_install_kernel_debs__install_aic8800_dkms_package() {
	[[ "${INSTALL_HEADERS}" != "yes" ]] || [[ "${KERNEL_HAS_WORKING_HEADERS}" != "yes" ]] && return 0
	[[ -z $AIC8800_TYPE ]] && return 0
	api_url="https://api.github.com/repos/Shadowrom2020/aic8800-dkms/releases/latest"
	latest_version=$(curl -s "${api_url}" | jq -r '.tag_name')
	aic8800_dkms_url="https://github.com/Shadowrom2020/aic8800-dkms/releases/download/${latest_version}/aic8800-dkms.deb"
	if [[ "${GITHUB_MIRROR}" == "ghproxy" ]]; then
		ghproxy_header="https://ghfast.top/"
		aic8800_dkms_url="${aic8800_dkms_url/https:\/\/github.com\//${ghproxy_header}github.com/}"
	fi
	use_clean_environment="yes" chroot_sdcard "wget ${aic8800_dkms_url} -P /tmp"
	display_alert "Installing aic8800 package, will build kernel module in chroot" "${EXTENSION}" "info"
	declare -ag if_error_find_files_sdcard=("/var/lib/dkms/aic8800*/*/build/*.log")
	use_clean_environment="yes" chroot_sdcard_apt_get_install "eject"
	use_clean_environment="yes" chroot_sdcard_apt_get_install "/tmp/aic8800-dkms.deb"
	use_clean_environment="yes" chroot_sdcard "rm -f /tmp/aic8800-dkms.deb"
}
