<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_supplier'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>	
			</li>
			<li>
				<a href="<?php echo base_url('admin/suppliers'); ?>"><?php _el('suppliers'); ?></a>
			</li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/suppliers/edit/').$supplier['user_id']; ?>" id="supplierform" method="POST">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('supplier'); ?></strong>
								</h5>
							</div>
						</div>
					</div>
					<!-- /Panel heading -->
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label><?php _el('firstname'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('firstname'); ?>" id="firstname" name="firstname" value="<?php echo $supplier['first_name']; ?>">
								</div>
								<div class="form-group">
									<label><?php _el('lastname'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('lastname'); ?>" id="lastname" name="lastname" value="<?php echo $supplier['last_name'];?>">
								</div>
								<div class="form-group">
									<label>Phone Number:</label>
									<input type="text" class="form-control" placeholder="Phone Number" id="mobile_no" name="mobile_no" value="<?php echo $supplier['phone_number'];?>">
								</div>
								<div class="form-group">
									<label><?php _el('email'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('email'); ?>" id="email" name="email" value="<?php echo $supplier['email'];?>" readonly>
								</div>
								<div class="form-group">							
									<label><?php _el('new_password'); ?>:</label>
									<input type="password" class="form-control" placeholder="<?php _el('enter_new_password_only_if_you_want_to_change_password'); ?>" id="newpassword" name="newpassword" value="" >											
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('role'); ?></label>
									<select class="select" name="role" id="role">
										
										<option value="<?php echo $supplier['login_as']; ?>" name="role" selected><?php echo $supplier['login_as']; ?>
										</option>
										
									</select>
								</div>
								<div class="form-group">
									<label><?php _el('status'); ?>:</label>
									<input type="checkbox" class="switchery" name="is_active" id="<?php echo $supplier['user_id']; ?>" <?php if($supplier['active_status']==1) { echo "checked";} ?> >
								</div>
							</div>
						</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
		</div>
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
		<button type="submit" class="btn btn-success" name="submit"><?php _el('save'); ?></button>
		<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->

<script type="text/javascript">
$("#supplierform").validate({
	rules: {
		firstname:
		{
			required: true,
		},	
        lastname:{
            required:true
        },
        // mobile_no:{
        //     required:true,
        // },
        email:{
            required:true,
        },
        
	},
	messages: {
		firstname: 
		{
			required:"<?php _el('please_enter_', _l('firstname')) ?>",
		},
        lastname:{
            required:"<?php _el('please_enter_', _l('lastname')) ?>",
        },
        // mobile_no:{
        //     required:"<?php _el('please_enter_', _l('mobile_no')) ?>",
        // },
        email:{
            required:"<?php _el('please_enter_', _l('email')) ?>",
        },
       
	}
});  
</script>

