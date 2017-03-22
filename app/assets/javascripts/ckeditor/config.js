/*
Copyright (c) 2003-2011, CKSource - Frederico Knabben. All rights reserved.
For licensing, see LICENSE.html or http://ckeditor.com/license
*/

var entry_id = $('#entry_id').val();

if (entry_id == undefined) {
  alert('Entry ID is undefined!\nCheck ckeditor/config.js');
};

CKEDITOR.editorConfig = function( config )
{
  // Define changes to default configuration here. For example:
  // config.language = 'fr';
  // config.uiColor = '#AADC6E';

  config.height = 500;

  /* Filebrowser routes */
  // The location of an external file browser, that should be launched when "Browse Server" button is pressed.
  config.filebrowserBrowseUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Flash dialog.
  config.filebrowserFlashBrowseUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of a script that handles file uploads in the Flash dialog.
  config.filebrowserFlashUploadUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Link tab of Image dialog.
  config.filebrowserImageBrowseLinkUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of an external file browser, that should be launched when "Browse Server" button is pressed in the Image dialog.
  config.filebrowserImageBrowseUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of a script that handles file uploads in the Image dialog.
  config.filebrowserImageUploadUrl = "/el_finder/?entry_id=" + entry_id;

  // The location of a script that handles file uploads.
  config.filebrowserUploadUrl = "/el_finder/?entry_id=" + entry_id;

  config.allowedContent = true;

  config.startupOutlineBlocks = true;

  // Toolbar groups configuration.
  config.toolbar = [
    {
      name: 'document',
      groups: [
        'mode',
        'document',
        'doctools'
      ],
      items: [
        'Source'
      ]
    },
    {
      name: 'clipboard',
      groups: [
        'clipboard',
        'undo'
      ],
      items: [
        'Cut',
        'Copy',
        'Paste',
        'PasteText',
        'PasteFromWord',
        '-',
        'Undo',
        'Redo'
      ]
    },
    {
      name: 'editing',
      groups: [
        'find',
        'selection',
        //'spellchecker'
      ],
      items: [
        'Find',
        'Replace',
        '-',
        'SelectAll',
        //'-',
        //'Scayt'
      ]
    },
    //{
      //name: 'forms',
      //items: [
        //'Form',
        //'Checkbox',
        //'Radio',
        //'TextField',
        //'Textarea',
        //'Select',
        //'Button',
        //'ImageButton',
        //'HiddenField'
      //]
    //},
    {
      name: 'links',
      items: [
        'Link',
        'Unlink',
        'Anchor'
      ]
    },
    {
      name: 'insert',
      items: [
        'Image',
        //'Flash',
        'Table',
        'HorizontalRule',
        'SpecialChar'
      ]
    },
    {
      name: 'paragraph',
      groups: [
        'list',
        'indent',
        'blocks',
        'align',
        'bidi'
      ],
      items: [
        'NumberedList',
        'BulletedList',
        '-',
        'Outdent',
        'Indent',
        '-',
        'Blockquote',
        'CreateDiv'
      ]
    },
    '/',
    //{
      //name: 'styles',
      //items: [
        //'Styles',
        //'Format',
        //'Font',
        //'FontSize'
      //]
    //},
    {
      name: 'styles',
      items: [
        'Format',
        '-',
        'JustifyLeft',
        'JustifyCenter',
        'JustifyRight',
        'JustifyBlock'
      ]
    },
    //{
      //name: 'colors',
      //items: [
        //'TextColor',
        //'BGColor'
      //]
    //},
    {
      name: 'basicstyles',
      groups: [
        'basicstyles',
        'cleanup'
      ],
      items: [
        'Bold',
        'Italic',
        'Underline',
        'Strike',
        'Subscript',
        'Superscript',
        '-',
        'RemoveFormat',
        '-',
        'ShowBlocks',
        '-',
        'Maximize'
      ]
    }
  ];

  config.toolbar_mini = [
    {
      name: 'paragraph',
      groups: [
        'list',
        'indent',
        'blocks',
        'align',
        'bidi'
      ],
      items: [
        'NumberedList',
        'BulletedList',
        '-',
        'Outdent',
        'Indent',
        '-',
        'Blockquote',
        'CreateDiv',
        '-',
        'JustifyLeft',
        'JustifyCenter',
        'JustifyRight',
        'JustifyBlock'
      ]
    },
    {
      name: 'styles',
      items: [
        'Font',
        'FontSize'
      ]
    },
    {
      name: 'colors',
      items: [
        'TextColor',
        'BGColor'
      ]
    },
    {
      name: 'basicstyles',
      groups: [
        'basicstyles',
        'cleanup'
      ],
      items: [
        'Bold',
        'Italic',
        'Underline',
        'Strike',
        'Subscript',
        'Superscript',
        '-',
        'RemoveFormat'
      ]
    },
    {
      name: 'insert',
      items: [
        'Image',
        'Table',
        'HorizontalRule',
        'SpecialChar'
      ]
    }
  ];

  CKEDITOR.on( 'dialogDefinition', function( ev ){
    var editor = ev.editor;
    var dialogName = ev.data.name;
    var dialogDefinition = ev.data.definition;
    var dialog = dialogDefinition.dialog;

    if (dialogName == 'image') {
      dialogDefinition.onOk = function(e) {
        var width = dialog.getValueOf('info', 'txtWidth');
        var height = dialog.getValueOf('info', 'txtHeight');
        var src = dialog.getValueOf('info', 'txtUrl');
        src = src.replace(/\/\d+-\d+\//, '/' + width + '-' + height + '/');
        var alt = dialog.getValueOf('info', 'txtAlt');
        var klass = dialog.getValueOf('advanced', 'txtGenClass');
        var style = dialog.getValueOf('advanced', 'txtdlgGenStyle');

        var img =
          "<img src='" + src + "'" +
          " width='" + width + "'" +
          " height='" + height + "'" +
          " alt='" + alt + "'" +
          " class='" + klass + "'" +
          " style='" + style + "' />";

        var target = dialog.getValueOf('Link', 'cmbTarget')
        if (target.length) {
          target = " target='" + target + "'";
        }

        var link = dialog.getValueOf('Link', 'txtUrl'),
            link_open = '',
            link_close = '';
        if (link.length) {
          link_open = "<a href='" + link + "'" + target + ">";
          link_close = "</a>";
        }

        element = CKEDITOR.dom.element.createFromHtml(link_open + img + link_close);

        editor.insertElement(element);
      };
    }
  });
};
