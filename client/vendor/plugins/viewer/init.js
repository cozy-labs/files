//jshint browser: true, strict: false, maxstatements: false
//
// Use Viewer.js to preview PDF and OpenDocument files
//
if (typeof window.plugins !== "object") {
  window.plugins = {};
}
window.plugins.viewer = {
  name: "Viewer",
  active: true,
  extensions: ['pdf', 'ods', 'odt'],
  getFiles: function (node) {
    return window.plugins.helpers.getFiles(this.extensions, node);
  },
  addGallery: function (params) {
    var files;
    files = this.getFiles();
    if (files.length > 0) {
      Array.prototype.forEach.call(files, function (elmt, idx) {
        window.plugins.helpers.addIcon(elmt, function () {
          var viewer;
          viewer = document.createElement('iframe');
          viewer.id = 'viewer';
          viewer.setAttribute('src', 'ViewerJS/#../' + elmt.dataset.fileUrl);
          viewer.setAttribute('height', window.innerHeight * 0.7);
          viewer.setAttribute('width', '100%');
          viewer.setAttribute('allowfullscreen', 'allowfullscreen');
          viewer.setAttribute('webkitallowfullscreen', true);
          window.plugins.helpers.modal({body: viewer.outerHTML, size: 'large'});
        });
      });
    }
  },
  onAdd: {
    condition: function (node) {
      return this.getFiles(node).length > 0;
    },
    action: function (node) {
      this.addGallery();
    }
  },
  onDelete: {
    condition: function (node) {
      return this.getFiles(node).length > 0;
    },
    action: function (node) {
      this.addGallery();
    }
  },
  listeners: {
    'load': function (params) {
      this.addGallery();
    }
  }
};
