package MjNCMS::Template::Filter::safe_page_html;
# (c) Fedor F Lejepekov, ffl.public@gmail.com, 2010
#Safe html tags for pages. NOT FOR comments or smth.

#
# Bender: My head! My precious head!
#   Stuped cun opener! 
#   You've killed my father and now you've come back for me!
#

BEGIN {
  use common::sense;
  use Template::Plugin::Filter;
  use base qw(Template::Plugin::Filter);
  use FindBin;
  use lib "$FindBin::Bin/../../..";
  use MjNCMS::Config qw/:vars/;
  use MjNCMS::Service qw/:subs /;
  
  #filter possibly unsafe html. EVIL :)
  #disallow all not allowed
  use HTML::StripScripts::Parser;
}

our $VERSION = 1.00;

sub new {
    my ($class, $context, $format) = @_;;
    $context->define_filter('safe_page_html', [ \&safe_page_html_filter_factory => 1 ]);
    return \&safe_page_html;
}

sub filter {
    my ($self, $html) = @_;
    return $self->safe_page_html($html);
}

sub _to_line ($) {
    my $str = shift;
    $str =~ s/(\r\n|\r|\n)/ /g;
    return $str;
} #-- _to_line

sub safe_page_html ($) {
    my $html = shift;
    return '' unless defined $html && length $html;

    #Multiline tags are resfuckingstricted by parser. wtf
    $html =~ s/<([^>]+?)>/'<' . (&_to_line($1)) . '>'/gem; 

    #This would be bad, evil, very unfair parser :)
    my $hss = HTML::StripScripts::Parser->new(
       { 
        Context => 'Flow',
        AllowSrc => 1,
        AllowHref => 1,
        AllowRelURL => 1,
        BanAllBut => [qw/

            b strong 
            u strike em 

            sup sub 

            ul li 

            p div span style br nobr

            a 

            h1 h2 h3 h4 h5 h6 

            img

            table tbody tr td th 
            
            object param embed

        /],
        Rules => {
            a => {
                'href' => '^(\/|ftp|http|https|ftp|)', #no javascript:, 
                
                'alt' => 1,
                'title' => 1,
                
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                
                'target' => 1, 
                'name' => 1, 
            },
            img => {
                'src' => '^(\/|ftp|http|https|ftp|)[^\"]+\.(gif|jpg|jpeg|png)$', 
                'lowsrc' => '^(\/|ftp|http|https|ftp|)[^\"]+\.(gif|jpg|jpeg|png)$', 
                'ilo-full-src' => '^(\/|ftp|http|https|ftp|)[^\"]+\.(gif|jpg|jpeg|png)$', 
                 
                'alt' => 1,
                'title' => 1,

                'width' => 1, 
                'height' => 1, 
                'hspace' => 1, 
                'wspace' => 1, 
                'border' => 1,
                 
                'class' => 1, 
                'style' => 1, 
                'align' => 1,  
                'float' => 1,
            },
            span => {
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                'float' => 1,
            },
            div => {
                'class' => 1, 
                'style' => 1, 
                'align' => 1, 
                'float' => 1,
            },
            table => {
                'cellpadding' => 1, 
                'cellspacing' => 1, 
                
                'width' => 1, 
                'height' => 1,
                'border' => 1,
                                 
                'align' => 1,  
                'style' => 1, 
                'class' => 1, 
                'float' => 1,
            },
            tr => {
                'rowspan' => 1, 
                'height' => 1, 
            },
            td => {
                'colspan' => 1, 
                'width' => 1, 
                'height' => 1, 
            },
            object => {
                'classid' => 1, 
                'codebase' => 1, 
            },
            param => {
                'name' => 1, 
                'value' => 1, 
            },
            embed => {
                'src' => '^(\/|ftp|http|https|ftp|)$', 
                'type' => 1, 
                'allowscriptaccess' => 1, 
                'allowfullscreen' => 1, 
                'width' => 1, 
                'height' => 1, 
            },
            #'*' => {
            #    'class' => 1, 
            #    'style' => 1, 
            #    'align' => 1, 
            #    '*' => 0, #no onclicks and other stuff
            #}, 
        },
        EscapeFiltered  => 1,
       },
       strict_comment => 1,
       strict_names   => 1,
       
    );

    #### fetch default allowed tags and attributes
    #
    my $context_whitelist = $hss->init_context_whitelist();
    my $attrib_whitelist = $hss->init_attrib_whitelist();
    #
    #### set additionally allowed html tags
    #$context_whitelist->{'Flow'}->{'object'} = 'object';
    #$context_whitelist->{'Inline'}->{'object'} = 'object';
    #$context_whitelist->{'object'}->{'param'} = 'EMPTY';
    #$context_whitelist->{'object'}->{'embed'} = 'EMPTY';
    #
    #### set additionally allowed html tag attributes
    #$attrib_whitelist->{'a'}->{'href'} = 'word';
    #$attrib_whitelist->{'a'}->{'name'} = 'word';
    #$attrib_whitelist->{'a'}->{'title'} = 'text';
    #$attrib_whitelist->{'a'}->{'class'} = 'wordlist';
    #$attrib_whitelist->{'a'}->{'target'} = 'word';

    #And why I've filled Rules {} above? Most dumb intreface I saw.

    #Defaults: HTML::StripScripts
    #near use vars qw(%_Attrib);
    
    $attrib_whitelist->{'a'}->{'href'} = 'href';
    
    $attrib_whitelist->{'a'}->{'alt'} = 'text';
    $attrib_whitelist->{'a'}->{'title'} = 'text';
    
    $attrib_whitelist->{'a'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'a'}->{'style'} = 'text';
    $attrib_whitelist->{'a'}->{'align'} = 'word';
    
    $attrib_whitelist->{'a'}->{'target'} = 'text';
    $attrib_whitelist->{'a'}->{'name'} = 'text';
    
    $attrib_whitelist->{'img'}->{'src'} = 'src';
    $attrib_whitelist->{'img'}->{'lowsrc'} = 'src';
    $attrib_whitelist->{'img'}->{'ilo-full-src'} = 'src';
    
    $attrib_whitelist->{'img'}->{'alt'} = 'text';
    $attrib_whitelist->{'img'}->{'title'} = 'text';
    
    $attrib_whitelist->{'img'}->{'width'} = 'size';
    $attrib_whitelist->{'img'}->{'height'} = 'size';
    $attrib_whitelist->{'img'}->{'hspace'} = 'size';
    $attrib_whitelist->{'img'}->{'vspace'} = 'size';
    $attrib_whitelist->{'img'}->{'border'} = 'size';
    
    $attrib_whitelist->{'img'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'img'}->{'style'} = 'text';
    $attrib_whitelist->{'img'}->{'align'} = 'word';
    $attrib_whitelist->{'img'}->{'float'} = 'word';
    
    $attrib_whitelist->{'div'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'div'}->{'style'} = 'text';
    $attrib_whitelist->{'div'}->{'align'} = 'word';
    $attrib_whitelist->{'div'}->{'float'} = 'word';
    
    $attrib_whitelist->{'span'}->{'class'} = 'wordlist';
    $attrib_whitelist->{'span'}->{'style'} = 'text';
    $attrib_whitelist->{'span'}->{'align'} = 'word';
    $attrib_whitelist->{'span'}->{'float'} = 'word';
    
    #table, tr, td, th seems ok
    $attrib_whitelist->{'table'}->{'cellpadding'} = 'size';
    $attrib_whitelist->{'table'}->{'cellspacing'} = 'size';
    $attrib_whitelist->{'table'}->{'border'} = 'size';

    $attrib_whitelist->{'object'}->{'classid'} = 'text';
    $attrib_whitelist->{'object'}->{'codebase'} = 'text';

    $attrib_whitelist->{'param'}->{'name'} = 'word';
    $attrib_whitelist->{'param'}->{'value'} = 'text';
    
    $attrib_whitelist->{'embed'}->{'classid'} = 'src';
    $attrib_whitelist->{'embed'}->{'type'} = 'text';
    $attrib_whitelist->{'embed'}->{'allowscriptaccess'} = 'text';
    $attrib_whitelist->{'embed'}->{'allowfullscreen'} = 'text';
    $attrib_whitelist->{'embed'}->{'width'} = 'size';
    $attrib_whitelist->{'embed'}->{'height'} = 'size';

    return $hss->filter_html($html);
    
}; #-- safe_html

sub safe_page_html_filter_factory {
    my ($context, @args) = @_;
    return sub {
        my $html = shift;
        return &safe_page_html($html, @args);
    }
}

1;
