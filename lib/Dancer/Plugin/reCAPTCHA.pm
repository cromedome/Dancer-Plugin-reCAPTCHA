package Dancer::Plugin::reCAPTCHA;
# ABSTRACT: Easily integrate reCAPTCHA into your Dancer applications
{
    $Dancer::Plugin::reCAPTCHA::VERSION = '0.1';
}

=head1 SYNOPSIS

    use Dancer::Plugin::reCAPTCHA;

    # In your form display....
    return template 'accounts/create', { 
        recaptcha => recaptcha_display(),
    };

    # In your template (TT2)
    [% recaptcha %]

    # In your validation code....
    my $challenge = param( 'recaptcha_challenge_field' );
    my $response  = param( 'recaptcha_response_field' );
    my $result    = recaptcha_check(
        $challenge, 
        $response,
    );
    die "User didn't match the CAPTCHA" unless $result->{ is_valid };

=cut

use Dancer ':syntax';
use Dancer::Plugin;
use Captcha::reCAPTCHA;

my $conf = plugin_setting();
my $rc   = Captcha::reCAPTCHA->new;

=method recaptcha_display( )

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
    return $rc->get_html( 
        $conf->{ public_key },
        undef,
        $conf->{ use_ssl },
        undef,
    );
};

=method recaptcha_check( $$ )

Verify that the value the user entered matches what's in the CAPTCHA.  This
methods takes two arguments: the challenge string and the response string.  
These are returned to your Dancer application as two parameters: 
F< recaptcha_challenge_field > and F< recaptcha_response_field >.

For example:

    my $challenge = param( 'recaptcha_challenge_field' );
    my $response  = param( 'recaptcha_response_field' );
    my $result    = recaptcha_check(
        $challenge, 
        $response,
    );
    die "User didn't match the CAPTCHA" unless $result->{ is_valid };

See L<Captcha::reCAPTCHA> for a description of the result hash.

=cut 

register recaptcha_check => sub {
    my ( $challenge, $response ) = @_;
    return $rc->check_answer(
        $conf->{ private_key },
        request->remote_address,
        $challenge,
        $response,
    );
};

=head2 TODO

Add a real test suite.

=head1 SEE ALSO

=for :list
* L<Captcha::reCAPTCHA>
* L<Dancer::Plugin>
* L<Dancer>

=cut 

register_plugin;
1;
