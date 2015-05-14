var gulp = require('gulp');
var gutil = require('gulp-util');
var bower = require('bower');
var concat = require('gulp-concat');
var sass = require('gulp-sass');
var minifyCss = require('gulp-minify-css');
var rename = require('gulp-rename');
var sh = require('shelljs');
var coffee = require('gulp-coffee');
var replace = require('gulp-replace-task');  
var args = require('yargs').argv;  
var fs = require('fs');

var paths = {
  sass_index: ['./src/waving/style.scss'],
  sass: ['./src/**/*.scss'],
  coffee: [
    './src/waving/**/*.coffee',
    //Ignore tests
    '!./src/waving/**/*.spec.coffee'
  ],
  js_folder: './www/js/',
  css_folder: './www/css/',
};

gulp.task('default', ['sass', 'coffee']);

gulp.task('sass', function(done) {
  gulp.src(paths.sass_index)
    .pipe(sass())
    .pipe(gulp.dest(paths.css_folder))
    .pipe(minifyCss({
      keepSpecialComments: 0
    }))
    .pipe(rename({ extname: '.min.css' }))
    .pipe(gulp.dest(paths.css_folder))
    .on('end', done);
});

gulp.task('coffee', function(done) {
  gulp.src(paths.coffee)
  .pipe(coffee({bare: true}).on('error', gutil.log))
  .pipe(concat('application.js'))
  .pipe(gulp.dest(paths.js_folder))
  .on('end', done);
});

gulp.task('watch', function() {
  gulp.watch(paths.sass, ['sass']);
  gulp.watch(paths.coffee, ['coffee']);
});

gulp.task('install', ['git-check'], function() {
  return bower.commands.install()
    .on('log', function(data) {
      gutil.log('bower', gutil.colors.cyan(data.id), data.message);
    });
});

gulp.task('git-check', function(done) {
  if (!sh.which('git')) {
    console.log(
      '  ' + gutil.colors.red('Git is not installed.'),
      '\n  Git, the version control system, is required to download Ionic.',
      '\n  Download git here:', gutil.colors.cyan('http://git-scm.com/downloads') + '.',
      '\n  Once git is installed, run \'' + gutil.colors.cyan('gulp install') + '\' again.'
    );
    process.exit(1);
  }
  done();
});

gulp.task('replace', function () {  
  var env = args.env || 'localdev';
  /* Read the settings from the right file */
  var filename = env + '.json';
  var settings = JSON.parse(fs.readFileSync('./config/' + filename, 'utf8'));

  // Replace each placeholder with the correct value for the variable.  
  gulp.src('./config/config.coffee')  
    .pipe(replace({
      patterns: [
        {
          match: 'apiUrl',
          replacement: settings.apiUrl
        },
        {
          match: 'env',
          replacement: settings.env
        }
      ]
    }))
    .pipe(gulp.dest('./src/waving'));
});
