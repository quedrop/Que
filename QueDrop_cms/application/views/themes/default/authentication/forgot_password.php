<div class="container" style="margin-top:100px;">
	
	<div class="row">
		<div class="col-md-4 col-md-offset-4">
            <?php $this->load->view('themes/default/includes/alerts'); ?>
            <h5 class="content-group"><?php _el('forgot_password'); ?>
            <br><small class="display-block"><?php _el('forgot_password_instructions'); ?></small></h5>
			<form id="recovery_form" method="post" action="<?php echo site_url('authentication/forgot_password') ?>">
				<div class="form-group">
					<small class="req text-danger">* </small>
                    <label><?php _el('email'); ?></label>
                    <input type="email" class="form-control" placeholder="<?php _el('email'); ?>" name="email" id="email">
				</div>						
				<button type="submit" class="btn btn-primary btn-block" name="submit"><?php _el('confirm'); ?></button>
                <a href="<?php echo site_url('authentication') ?>"><?php _el('login');?></a>
			</form>
		</div>
	</div>	
<script type="text/javascript">
$("#recovery_form").validate({
        rules: {
            email: {
                required: true,
                email: true
            }
        },
        messages: {
            email: {
                required:"<?php _el('please_enter_', _l('email')) ?>",
                email:"<?php _el('please_enter_valid_',_l('email')) ?>"
            }
        }
    }); 
</script>
