# NAME

WebService::Simple - Simple Interface To Web Services APIs

# SYNOPSIS

    use WebService::Simple;

    # Simple use case
    my $flickr = WebService::Simple->new(
      base_url => "http://api.flickr.com/services/rest/",
      param    => { api_key => "your_api_key", }
    );

    # send GET request to 
    # http://api.flickr.com/service/rest/?api_key=your_api_key&method=flickr.test.echo&name=value
    $flickr->get( { method => "flickr.test.echo", name => "value" } );

    # send GET request to 
    # http://api.flickr.com/service/rest/extra/path?api_key=your_api_key&method=flickr.test.echo&name=value
    $flickr->get( "extra/path",
      { method => "flickr.test.echo", name => "value" });

# DESCRIPTION

WebService::Simple is a simple class to interact with web services.

It's basically an LWP::UserAgent that remembers recurring API URLs and
parameters, plus sugar to parse the results.

# METHODS

- new(_%args_)

        my $flickr = WebService::Simple->new(
            base_url => "http://api.flickr.com/services/rest/",
            param    => { api_key => "your_api_key", },
            # debug    => 1
        );

    Create and return a new WebService::Simple object.
    "new" Method requires a base\_url of Web Service API.
    If debug is set, dump a request URL in get or post method.

- get(_\[$extra\_path,\] $args_)

        my $response =
          $flickr->get( { method => "flickr.test.echo", name => "value" } );

    Send GET request, and you can get  the WebService::Simple::Response object.
    If you want to add a path to base URL, use an option parameter.

        my $lingr = WebService::Simple->new(
            base_url => "http://www.lingr.com/",
            param    => { api_key => "your_api_key", format => "xml" }
        );
        my $response = $lingr->get( 'api/session/create', {} );

- post(_\[$extra\_path,\] $args_)

    Send POST request.

- request\_url(_$extra\_path, $args_)

    Return request URL.

- base\_url
- basic\_params
- cache

    Each request is prepended by an optional cache look-up. If you supply a cache
    object upon new(), the module will look into the cache first.

- response\_parser

# SUBCLASSING

For better encapsulation, you can create subclass of WebService::Simple to
customize the behavior

    package WebService::Simple::Flickr;
    use base qw(WebService::Simple);
    __PACKAGE__->config(
      base_url => "http://api.flickr.com/services/rest/",
      upload_url => "http://api.flickr.com/services/upload/",
    );

    sub test_echo
    {
      my $self = shift;
      $self->get( { method => "flickr.test.echo", name => "value" } );
    }

    sub upload
    {
      my $self = shift;
      local $self->{base_url} = $self->config->{upload_url};
      $self->post( 
        Content_Type => "form-data",
        Content => { title => "title", description => "...", photo => ... },
      );
    }

# PARSERS

Web services return their results in various different formats. Or perhaps
you require more sophisticated results parsing than what WebService::Simple
provides.

WebService::Simple by default uses XML::Simple, but you can easily override
that by providing a parser object to the constructor:

    my $service = WebService::Simple->new(
      response_parser => AVeryComplexParser->new,
      ...
    );
    my $response = $service->get( ... );
    my $thing = $response->parse_response;

For example. If you want to set XML::Simple options, use WebService::Simple::Parser::XML::Simple
including this module:

    use WebService::Simple;
    use WebService::Simple::Parser::XML::Simple;
    use XML::Simple;
    
    my $xs = XML::Simple->new( KeyAttr => [], ForceArray => ['entry'] );
    my $service = WebService::Simple->new(
        base_url => "http://gdata.youtube.com/feeds/api/videos",
        param    => { v => 2 },
        response_parser =>
          WebService::Simple::Parser::XML::Simple->new( xs => $xs ),
    );

This allows great flexibility in handling different Web Services

# CACHING

You can cache the response of Web Service by using Cache object.

    my $cache   = Cache::File->new(
        cache_root      => '/tmp/mycache',
        default_expires => '30 min',
    );
    
    my $flickr = WebService::Simple->new(
        base_url => "http://api.flickr.com/services/rest/",
        cache    => $cache,
        param    => { api_key => "your_api_key, }
    );

# REPOSITORY

https://github.com/yusukebe/WebService-Simple

# AUTHOR

Yusuke Wada  `<yusuke@kamawada.com>`

Daisuke Maki `<daisuke@endeworks.jp>`

Matsuno Tokuhiro

Naoki Tomita (tomi-ru)

# COPYRIGHT AND LICENSE

This module is free software; you can redistribute it
and/or modify it under the same terms as Perl itself.
See [perlartistic](https://metacpan.org/pod/perlartistic).
