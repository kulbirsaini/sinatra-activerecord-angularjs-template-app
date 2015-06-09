module.exports = function(grunt){
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    project: {
      name: '<%= pkg.name %>',
      app: 'public',
      assets: 'public/assets',
      css: 'public/assets/css',
      scss: 'public/assets/scss',
      js: 'public/assets/js',
      minjs: 'public/assets/minjs',
      components: 'public/bower_components'
    },
    copy: {
      main: {
        expand: true,
        flatten: true,
        src: '<%= project.components %>/bootstrap-sass/assets/fonts/bootstrap/*.*',
        dest: '<%= project.assets %>/fonts/bootstrap/'
      }
    },
    sass: {
      options: {
        sourcemap: 'none'
      },
      dist: {
        files: [{
          expand: true,
          flatten: true,
          ext: '.css',
          src: ['<%= project.scss %>/*.scss'],
          dest: '<%= project.css %>'
        }]
      }
    },
    cssmin: {
      dist: {
        files: [{
          expand: true,
          flatten: true,
          ext: '.min.css',
          src: '<%= project.css %>/*.css',
          dest: '<%= project.css %>'
        }]
      },
    },
    uglify: {
      options: {
        mangle: 'sort',
      },
      js: {
        files: [{
          '<%= project.minjs %>/application.min.js': '<%= project.js %>/*.js'
        }]
      }
    },
    watch: {
      sass: {
        files: '<%= project.scss %>/*.scss',
        tasks: ['sass']
      },
      css: {
        files: ['<%= project.css %>/*.css', '!<%= project.css %>/*.min.css'],
        tasks: ['cssmin']
      },
      js: {
        files: '<%= project.js %>/*.js',
        tasks: ['uglify']
      }
    }
  });
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-sass');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.registerTask('default',['copy', 'sass', 'cssmin', 'uglify', 'watch']);
}
