CKEDITOR.editorConfig = function( config ) {
  config.language = 'de';
  config.allowedContent = 'a[!href,target]; ul; li; ol; h2; h3; strong; b; i; em; br; img[alt,!src]{width,height}; table[align](*); tr; th[colspan,rowspan]{text-align}; td[colspan,rowspan]{text-align}';

  config.toolbar = [
    { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ], items: [ 'Bold', 'Italic', '-', 'RemoveFormat' ] },
    { name: 'styles', items: [ 'Format', 'Styles' ] },
    { name: 'insert', items: [ 'Image', 'Table' ] },
    { name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ], items: [ 'NumberedList', 'BulletedList' ] },
    { name: 'links', items: [ 'Link', 'Unlink' ] }
  ];

  config.format_tags = 'p;h2;h3';

  config.filebrowserBrowseUrl = '/assets/';
  config.filebrowserImageBrowseUrl = '/image_assets/';

  config.toolbar_mini = config.toolbar;

};
