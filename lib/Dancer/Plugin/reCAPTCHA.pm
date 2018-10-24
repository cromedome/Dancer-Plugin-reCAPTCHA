package Dancer::Plugin::reCAPTCHA;
# ABSTRACT: Easily integrate reCAPTCHA into your Dancer applications
{
    $Dancer::Plugin::reCAPTCHA::VERSION = '0.10';
}

=head1 SYNOPSIS

    # In your config.yml 
    plugins: 
        reCAPTCHA: 
            public_key: "public key goes here" 
            private_key: "private key goes here" 
            theme: "dark"
            type: "image"
            size: "normal"

    # In your Dancer app...
    use Dancer::Plugin::reCAPTCHA;

    # In your form display route...
    return template 'accounts/create', { 
        recaptcha => recaptcha_display(),
    };

    # In your template (TT2)
    [% recaptcha %]

    # In your validation code....
    my $response  = param( 'recaptcha_response_field' );
    my $result    = recaptcha_check( $response );
    die "User didn't match the CAPTCHA" unless $result->{ success };

=cut

use Dancer ':syntax';
use Dancer::Plugin;
use Captcha::reCAPTCHA::V2;

my $rc = Captcha::reCAPTCHA::V2->new;

=method recaptcha_display()

Generates the HTML needed to display the CAPTCHA.  This HTML is returned as
a scalar value, and can easily be plugged into the template system of your 
choice.

Using Template Toolkit as an example, this might look like:

    # Code
    return template 'accounts/create', { 
        recaptcha => recaptcha_display(),
    };

    # In your accounts/create template
    [% recaptcha %]

=cut

register recaptcha_display => sub {
    my $conf = plugin_setting();
    my %options = map { $_ => $conf->$_ if defined $conf->$_ } (qw[ theme type size ]);
    return $rc->html(
        $conf->{ public_key },
        { %options }
    );
};

=method recaptcha_check()

Verify that the value the user entered matches what's in the CAPTCHA.  This
methods takes an argument that is the response string.
These are returned to your Dancer application as the parameter
F< g-recaptcha-response >.

For example:

    my $response  = param( 'g-recaptcha-response' );
    my $result    = recaptcha_check( $response );
    die "User didn't match the CAPTCHA" unless $result->{ success };

See L<Captcha::reCAPTCHA::V2> for a description of the result hash.

=cut 

register recaptcha_check => sub {
    my ( $response ) = @_;
    my $conf = plugin_setting();
    return $rc->verify(
        $conf->{ private_key },
        $response,
        request->remote_address,
    );
};

=head2 TODO

Add a real test suite.

=head1 CREDITS

The following people have contributes to C<Dancer::Plugin::reCAPTCHA> in some 
way, either through bug reports, code, suggestions, or moral support:

Mohammad S Anwar
Shawn Sorichetti

=head1 SEE ALSO

=for :list
* L<Captcha::reCAPTCHA::V2>
* L<Dancer::Plugin>
* L<Dancer>

=cut 

register_plugin;
1;
