[% USE loc -%]
[% USE bytestream -%]
[% IF TT_VARS.page_id && (matches = TT_VARS.page_id.match('^\d+$')) -%]
    [% page_id = TT_VARS.page_id -%]
    [% pages_res=TT_CALLS.content_get_pagerecord({
        'res_ashash' => 1, 
        'page_id' => page_id, 
        'get_access_roles' => 1, 
        'get_transes' => 1, 
        'skip_access_roles_rule' => 1,
        'disable_autotranslate' => 1, 
        'skip_pagination' => 1,
    }) -%]
    [%# pages_res.q -%]
    [% IF pages.message -%]
        [% loc('Pages list receiving fail') | html -%]:[% pages.message | html -%]
        [% RETURN -%]
    [% END -%]
    [% UNLESS pages_res.pages_res.$page_id && pages_res.pages_res.$page_id.page_id && pages_res.pages_res.$page_id.is_writable -%]
        [% loc('Page id not found or no access') | html -%]
        [% RETURN -%]
    [% END -%]
    [% page_access_roles=pages_res.pages_access_roles.$page_id -%]
    [% UNLESS page_access_roles -%]
        [% page_access_roles={} -%]
    [% END -%]
[% ELSE -%]
    [% loc('page id is not \d+') | html -%]
    [% RETURN -%]
[% END #IF TT_VARS.page_id -%]
[% TT_VARS.CSS.push(SESSION.THEME_URLPATH _ '/_static/css/datepicker/datepicker_vista.css50') -%]
[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/datepicker.js50') -%]
[% TT_VARS.JS.push(SESSION.THEME_URLPATH _ '/_static/js/ckeditor/ckeditor.js') -%]
[% TT_VARS.JS.push(bytestream(SESSION.THEME_URLPATH, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') _ '/admin/js/pages.js') -%]
[% cat_ids=TT_CALLS.content_get_catrecord_tree('0') -%]
[% cat_res=TT_CALLS.content_get_catrecord(cat_ids, {
        #'disable_autotranslate' => 1, 
}) -%]
[% SESSION.DATE.rest() -%]
[% curr_date = SESSION.DATE.to_fstring(SESSION.LOC.get_dt_fmt()) -%]
[% page = pages_res.pages_res.$page_id -%]
<table border="0" cellspacing="1" cellpadding="4" align="center" width="100%" class="bordercolor">
    <tr class="titlebg">
        <td align="center" [% IF colspan %] colspan="[% colspan %]"[% END %] class="largetext">
            [% loc('Edit a page') %]
        </td>
    </tr>
    <tr class="windowbg">
        <td class="windowbg lual" style="padding: 7px;"[% IF colspan %] colspan="[% colspan %]"[% END %]>
            <form onSubmit="javascript:submit_editpage_frm();return false;" name="save_edited_page_frm" id="save_edited_page_frm" action="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/editpage/[% page_id %]" method="post" accept-charset="[% TT_VARS.html_charset %]">
                <table class="w100">
                    <tr>
                        <td class="lual">
                            <table class="w100 p5 lual">
                                <tr>
                                    <td class="w15 nwp">
                                        <label for="page_header" title="[% loc('Up to 64 chars') | html -%]">[% loc('Page header') | html -%]: </label>
                                    </td>
                                    <td class="w25">
                                        <input type="text" name="page_header" id="page_header" size="24" maxlength="64" value="[% page.header | html %]"/>
                                    </td>
                                    <td class="w20 nwp">
                                        <label for="page_cat">[% loc('Page category') | html -%]: </label>
                                    </td>
                                    <td>
                                        [% INCLUDE common_catlist_fmt.tpl t_cattree=cat_ids, t_catrecords=cat_res, t_nocat=1, t_name='parent_cat_id', t_selected={ ${page.cat_id} => 1 } -%]
                                    </td>
                                </tr>
                                <tr>
                                    <td class="nwp">
                                        <label for="page_slug" title="[% loc('Up to 128 chars, no "/some/else" paths') | html -%]">[% loc('Page slug') | html -%]: </label>
                                    </td>
                                    <td>
                                        <input type="text" name="page_slug" id="page_slug" size="24" maxlength="128" value="[% page.slug | html %]"/>
                                    </td>
                                    <td class="nwp">
                                        <label for="page_lang">[% loc('Page default lng') | html -%]:</label> 
                                    </td>
                                    <td>
                                        [% INCLUDE common_langlist_fmt.tpl t_name='page_lang', t_selected={ ${page.lang} => 1 } -%]
                                    </td>
                                </tr>
                            </table>
                            <label for="page_intro" class="vat">[% loc('Page intro') | html -%]:</label><br />
                            <textarea name="page_intro" id="page_intro" rows="15" cols="75">[% page.intro | html %]</textarea><br />
                            <label for="page_body" class="vat">[% loc('Page body') | html -%]:</label><br />
                            <textarea name="page_body" id="page_body" rows="30" cols="75">[% page.body | html %]</textarea>
                        </td>
                        <td class="w35 lual">
                            <input type="submit" value="   [% loc('Save page') | html %]   " style="float:right;margin-right:10px;"/><br /><br />
                            <div id="RightOptsBlock" class="w100 layoutElement iv">
                                <ul id="tabs_block">
                                    <li title="tab_block_publish">Publish opts</li>
                                    <li title="tab_block_seo">Seo opts</li>
                                    <li title="tab_block_access">Access opts</li>
                                </ul>
                            </div>
                            <div id="tab_block_publish">
                                <table class="w100 nwp">
                                    <tr>
                                        <td>
                                            <label for="page_ispublished">[% loc('Is published') | html -%]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_ispublished" id="page_ispublished" value="1" class="vam"[% IF page.is_published %] checked="checked"[% END %]/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="page_showintro">[% loc('Show intro') | html -%]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_showintro" id="page_showintro" value="1" class="vam"[% IF page.showintro %] checked="checked"[% END %]/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="lual">
                                            <label for="page_allowcomments">[% loc('Allow comments') | html -%]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_allowcomments" id="page_allowcomments" value="1" class="vam"[% IF page.allow_comments %] checked="checked"[% END %]/> <br />
                                            <input[% IF page.comments_mode && page.comments_mode=='comment' %] checked="checked"[% END %] type="radio" name="page_comments_mode" id="page_comments_mode_comments" value="comment" class="vam"/> 
                                                <label for="page_comments_mode_comments" title="[% loc('As comments @ bottom') -%]">[% loc('Comments') | html -%]</label> / 
                                            <input[% IF page.comments_mode && page.comments_mode=='fthread' %] checked="checked"[% END %] type="radio" name="page_comments_mode" id="page_comments_mode_fthread" value="fthread" class="vam"/> 
                                                <label for="page_comments_mode_fthread" title="[% loc('As forum thread') -%]">[% loc('Forum thread') | html -%]</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            [% loc('Author') | html -%]:
                                        </td>
                                        <td>
                                            [% INCLUDE common_userlist_fmt.tpl t_name='page_author_id', t_selected={${page.author_id} => 1, } -%]
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="page_dt_created">[% loc('Date created') | html -%]:</label>
                                        </td>
                                        <td class="nwp">
                                            <input type="text" name="page_dt_created" id="page_dt_created" size="19" maxlength="19" value="[% page.dt_created_fmt | html %]" class="datepicker_field"/><br /
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="nwp">
                                            <label for="page_dt_publishstart">[% loc('Published Start') | html -%]:</label>
                                        </td>
                                        <td>
                                            <input type="text" name="page_dt_publishstart" id="page_dt_publishstart" size="19" maxlength="19" value="[% page.dt_publishstart_fmt | html %]" class="datepicker_field"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="nwp">
                                            <label for="page_dt_publishend">[% loc('Published End') | html -%]:</label>
                                        </td>
                                        <td>
                                            <input type="text" name="page_dt_publishend" id="page_dt_publishend" size="19" maxlength="19" value="[% page.dt_publishend_fmt | html %]" class="datepicker_field"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="tab_block_seo">
                                <table class="w100 nwp">
                                    <tr>
                                        <td>
                                            <label for="page_use_customtitle">[% loc('Use custom title') | html -%]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_use_customtitle" id="page_use_customtitle" value="1" class="vam"[% IF page.use_customtitle %] checked="checked"[% END %]/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="page_custom_title">[% loc('Custom title') | html -%]:</label>
                                        </td>
                                        <td>
                                            <input type="text" name="page_custom_title" id="page_custom_title" size="19" maxlength="128"  value="[% page.custom_title | html %]"/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label for="page_descr">[% loc('Description') | html -%]:</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <textarea name="page_descr" id="page_descr" rows="3" cols="30">[% page.descr | html %]</textarea><br />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label for="page_keywords">[% loc('Keywords') | html -%]:</label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <textarea name="page_keywords" id="page_keywords" rows="3" cols="30">[% page.keywords | html %]</textarea><br />
                                        </td>
                                    </tr>
                                </table>
                            </div>
                            <div id="tab_block_access">
                                <table class="w100 nwp">
                                    <tr>
                                        <td>
                                            <label for="page_use_access_roles">[% loc('Limit access roles') | html %]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_use_access_roles" id="page_use_access_roles" value="1" class="vam"[% IF page.use_access_roles %] checked="checked"[% END %]/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <label for="page_access_roles">[% loc('Access roles') | html %]:</label><br />
                                            [% INCLUDE common_roleslist_fmt.tpl t_selmultible=6, t_name='page_access_roles', t_selected=page_access_roles -%]
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="page_use_password">[% loc('Use password') | html %]?</label>
                                        </td>
                                        <td>
                                            <input type="checkbox" name="page_use_password" id="page_use_password" value="1" class="vam"[% IF page.use_password %] checked="checked"[% END %]/>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <label for="page_password">[% loc('Page password') | html %]:</label>
                                        </td>
                                        <td class="nwp">
                                            <input type="text" name="page_password" id="page_password" size="19" maxlength="64" value="[% page.password | html %]"/>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                </table>
                <input type="hidden" name="referer" value="[% bytestream(SESSION.ADM_URL, 'url_escape', 'A-Za-z0-9\/\-\.\_\~') %]/content/pages?rnd=[% SESSION.RND %]" />
                <input type="hidden" name="rnd" value="[% SESSION.RND %]" />
            </form>

        </td>
    </tr>
</table>
<script type="text/javascript" language="javascript">
    
    locale_pages.set('save_page', '[% loc('Save page') | html %]');
    window.addEvent('domready', function() {
        $('RightOptsBlock').removeClass('iv');
        layout = new Jx.Layout('RightOptsBlock', {
            position:'relative',
            width: '100%',
            height: 300
        }).resize();
        var tabbox = new Jx.TabBox({
                postion:'top',
                parent: $('RightOptsBlock')
            }).add(
                new Jx.Button.Tab({
                    label: '[% loc('Publish Opts') | html %]', 
                    content: $('tab_block_publish')
                }),
                new Jx.Button.Tab({
                    label: '[% loc('Seo Opts') | html %]', 
                    content:  $('tab_block_seo')
                }),
                new Jx.Button.Tab({
                    label: '[% loc('Access Opts') | html %]', 
                    content:  $('tab_block_access')
                })
            );

        new DatePicker('.datepicker_field', {});
        
        CKEDITOR.replace( 'page_intro', {
            skin : 'v2', 
             toolbar : 'MjCMS_Intro',
            
            filebrowserBrowseUrl: '/_static/js/FileManager.shtml',
            filebrowserImageBrowseUrl : '/_static/js/FileManager.shtml',
            filebrowserFlashBrowseUrl : '/_static/js/FileManager.shtml',
            filebrowserWindowWidth : '880',
            filebrowserWindowHeight : '600'
            
        });
        CKEDITOR.replace( 'page_body', {
            skin : 'v2', 
            
            filebrowserBrowseUrl: '/_static/js/FileManager.shtml',
            filebrowserImageBrowseUrl : '/_static/js/FileManager.shtml',
            filebrowserFlashBrowseUrl : '/_static/js/FileManager.shtml',
            filebrowserWindowWidth : '880',
            filebrowserWindowHeight : '600'
        });

    });
    
</script>
