use strict;
use Test::More;
use WebService::Simple;
use URI::QueryParam;

subtest 'no default param / post()' => sub
{
    my $ws = WebService::Simple->new(
        base_url => 'http://example.com/',
    );

    my $req;
    $ws->add_handler(request_send => sub {
        $req = shift;
        HTTP::Response->new(200, 'OK');
    });

    $ws->post();
    is($req->uri->as_string, 'http://example.com/', "no extra_path");
    
    $ws->post({ bar => 123 });
    is($req->uri->as_string, 'http://example.com/', "no extra_path + args");
    is($req->content, 'bar=123', "no extra_path + args");

    $ws->post({ bar => 123 }, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/', "no extra_path + args + header");
    is($req->content, 'bar=123', "no extra_path + args + header");
    is($req->header('X-Test'), 'boo', "no extra_path + args + header");

    $ws->post({}, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/', "empty args + header");
    is($req->header('X-Test'), 'boo', "empty args + header");

    $ws->post('foo');
    is($req->uri->as_string, 'http://example.com/foo', "extra_path");

    $ws->post('foo', { bar => 123 });
    is($req->uri->as_string, 'http://example.com/foo', "extra_path + args");
    is($req->content, 'bar=123', "extra_path + args");
    
    $ws->post('foo', { bar => 123 }, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/foo', "extra_path + args + header");
    is($req->content, 'bar=123', "extra_path + args + header");
    is($req->header('X-Test'), 'boo', "extra_path + args + header");
    
    $ws->post({ bar => 123 }, 'Content' => { xxx => 'yyy' });
    is($req->content, 'xxx=yyy', "Content overwriting default_arg and arg");
    
    $ws->post('Content' => { xxx => 'yyy' });
    is($req->uri->as_string, 'http://example.com/Content', "first 'Content' is used as extra_path(maybe wrong)");
    is($req->content, 'xxx=yyy', "first 'Content' is used as extra_path(maybe wrong)");
    
    $ws->post('X-Test' => 'boo', 'Content' => { xxx => 'yyy' });
    is($req->uri->as_string, 'http://example.com/', "no extra_path and no extra args");
    is($req->content, 'xxx=yyy', "no extra_path and no extra args");
    is($req->header('X-Test'), 'boo', "no extra_path and no extra args");
};


subtest 'with default param / post()' => sub
{
    my $ws = WebService::Simple->new(
        base_url => 'http://example.com/',
        param   =>  { aaa => 'zzz' },
    );
    
    my $req;
    $ws->add_handler(request_send => sub {
        $req = shift;
        HTTP::Response->new(200, 'OK');
    });

    my $query_url = URI->new();

    $ws->post();
    is($req->uri->as_string, 'http://example.com/', "no extra_path");
    
    $ws->post({ bar => 123 });
    is($req->uri->as_string, 'http://example.com/', "no extra_path + args");
    $query_url->query($req->content);
    is($query_url->query_param('bar'), 123, "extra_path + args");
    is($query_url->query_param('aaa'), 'zzz', "extra_path + args");

    $ws->post({ bar => 123 }, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/', "no extra_path + args + header");
    $query_url->query($req->content);
    is($query_url->query_param('bar'), 123, "extra_path + args");
    is($query_url->query_param('aaa'), 'zzz', "extra_path + args");
    is($req->header('X-Test'), 'boo', "no extra_path + args + header");

    $ws->post({}, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/', "empty args + header");
    is($req->header('X-Test'), 'boo', "empty args + header");

    $ws->post('foo');
    is($req->uri->as_string, 'http://example.com/foo', "extra_path");

    $ws->post('foo', { bar => 123 });
    is($req->uri->as_string, 'http://example.com/foo', "extra_path + args");
    $query_url->query($req->content);
    is($query_url->query_param('bar'), 123, "extra_path + args");
    is($query_url->query_param('aaa'), 'zzz', "extra_path + args");
    
    $ws->post('foo', { bar => 123 }, 'X-Test' => 'boo');
    is($req->uri->as_string, 'http://example.com/foo', "extra_path + args + header");
    $query_url->query($req->content);
    is($query_url->query_param('bar'), 123, "extra_path + args + header");
    is($query_url->query_param('aaa'), 'zzz', "extra_path + args + header");
    is($req->header('X-Test'), 'boo', "extra_path + args + header");
    
    $ws->post({ bar => 123 }, 'Content' => { xxx => 'yyy' });
    is($req->content, 'xxx=yyy', "Content overwriting default_arg and arg");
};

done_testing();
