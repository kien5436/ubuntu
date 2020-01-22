const sass = require('node-sass');
const { writeFile } = require('fs');

const files = [
	'gnome-shell/gnome-shell.scss',
	'gtk-3.20/gtk.scss',
	'gtk-3.20/gtk-dark.scss',
];

const callback = (err, result) => {

	if (err) throw err;

	const filename = result.stats.entry.replace(/s?[ac]ss$/, 'css');

	writeFile(filename, result.css, err => {

		if (err) throw err;

		console.log(filename);
	});
};

for (let i = files.length; --i >= 0;) {

	sass.render({
		file: files[i],
		outputStyle: 'compressed',
		precision: 2,
	}, callback);
}