<?php
/**
 * Righteous Sandbox JSON Parser
 * 
 * This is a very simple script that parses a few preferences from the optional
 * .righteous-sandbox.json file.
 */

if (is_file('/share/.righteous-sandbox.json')) {
	$data = file_get_contents('/share/.righteous-sandbox.json');
	$data = json_decode($data, true) ?? array();

	// Normalize the bools.
	foreach (array('apt_update', 'just_list', 'npm_install', 'rust_update') as $k) {
		$data[$k] = (bool) ($data[$k] ?? false);
	}

	// Run apt updates.
	if ($data['apt_update']) {
		passthru('apt-get update -qq');
		passthru('DEBIAN_FRONTEND=noninteractive apt-fast dist-upgrade -y');
		passthru('clear');
	}

	// Run NPM updates.
	if ($data['npm_install']) {
		passthru('cd /share && npm i');
		passthru('chown -R --reference /share/package.json /share/node_modules');
		passthru('clear');
	}

	// Clear Cargo.lock.
	if (is_file('/share/Cargo.lock')) {
		unlink('/share/Cargo.lock');
	}

	$has_justfile = is_file('/share/justfile');

	// Run Just init.
	$data['just_init'] = trim($data['just_init'] ?? '');
	if ($has_justfile && ! empty($data['just_init'])) {
		passthru('cd /share && just ' . $data['just_init']);
	}

	// Update Rust.
	if ($data['rust_update']) {
		passthru('env RUSTUP_PERMIT_COPY_RENAME=true rustup --quiet update');

		if (is_file('/share/Cargo.toml')) {
			passthru('cd /share && cargo outdated || true');
			echo "\n";
		}
	}

	// List Just recipes.
	if ($has_justfile && $data['just_list']) {
		passthru('cd /share && just --list');
	}
}
