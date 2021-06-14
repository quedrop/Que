<?php defined('BASEPATH') or exit('No direct script access allowed');
/**
 * Sends an email.
 *
 * @param  str  $email    The email
 * @param  str  $subject  The subject
 * @param  str  $message  The message
 *
 * @return bool True if mail is sent. False otherwise.
 */
function send_email($email, $subject, $message)
{
	
	$from = 'demo.narola@gmail.com'; 
    $CI =& get_instance();
    $CI->load->library('email');
    $CI->load->config('email');
        $result = $CI->email
            ->from($from)
            ->to($email)
            ->subject($subject)
            ->message($message)
            // ->attach($attachment)
            ->send();
      
			echo $CI->email->print_debugger(); 
    return $result;
	
}

?>