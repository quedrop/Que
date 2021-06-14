<div class="container" style="margin-top:100px;">
	
	<div class="row">
		<div class="col-md-4 col-md-offset-4">
            <?php $this->load->view('themes/default/includes/alerts'); ?>
            <h5 class="content-group"><?php _el('reset_password');?></h5>
			<form id="reset_form" method="post" action="<?php echo site_url($this->uri->uri_string()); ?>">
				<div class="form-group">
					<small class="req text-danger">* </small>
                    <label><?php _el('new_password'); ?></label>
                    <input type="password" class="form-control" placeholder="<?php _el('new_password');?>" name="password" id="password">
				</div>
                <div class="form-group">
                    <small class="req text-danger">* </small>
                    <label><?php _el('confirm_password'); ?></label>
                    <input type="password" name="confirm_password" class="form-control" placeholder="<?php _el('confirm_password');?>" id="confirm_password">
                </div>						
				<button type="submit" class="btn btn-primary btn-block" name="submit"><?php _el('reset_password'); ?></button>

                <a href="<?php echo site_url('authentication') ?>"><?php _el('login');?></a>
			</form>
		</div>
	</div>	
<script type="text/javascript">
$("#reset_form").validate({
        rules: {
            password: {
                required: true,
                minlength: 8
            },
            confirm_password: {
                required: true,
                equalTo: "#password"
            }
        },
        messages:{
            password: {
                required: "<?php _el('please_enter_', _l('password')) ?>",
                minlength: "<?php _el('password_min_length_must_be_', 8)?>"
            },
            confirm_password: {
                required: "<?php _el('please_enter_', _l('confirm_password')) ?>",
                equalTo: "<?php _el('conf_password_donot_match')?>"
            },
        }
    });
</script>
