<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_driver'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/drivers'); ?>"><?php _el('drivers'); ?></a>
			</li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form action="<?php echo base_url('admin/drivers/edit/').$driver['user_id']; ?>" id="profileform" method="POST">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('drivers'); ?></strong>
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
									<small class="req text-danger">* </small>
									<label><?php _el('firstname'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('firstname'); ?>" id="firstname" name="firstname" value="<?php echo $driver['first_name']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('lastname'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('lastname'); ?>" id="lastname" name="lastname" value="<?php echo $driver['last_name']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('email'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('email'); ?>" id="email" name="email" class="email"value="<?php echo $driver['email']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('mobile_no'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('mobile_no'); ?>" id="mobile_no" name="mobile_no" value="<?php echo $driver['phone_number']; ?>">
								</div>
								<!-- <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('vehicle_type'); ?>:</label>
									<select name="vehicle_type" id="vehicle_type" class="select">
										<option value="">Select Vehicle Type</option>
										<?php
											if(!empty($vehicle_type)) {
												foreach($vehicle_type as $type) {
													?>
													<option value="<?php echo $type['vehicle_type_id'];?>" <?php if($driver['vehicle_type_id'] == $type['vehicle_type_id']) {echo "selected";}?>><?php echo $type['vehicle_type'];?></option>
													<?php
												}
											}
										?>
									</select>
								</div> -->
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('licence_photo'); ?>:</label>
									<input type="file" name="licence_photo" id="licence_photo" class="form-control">
									<input type="hidden" name="old_licence" id="old_licence" value="<?php echo $driver['licence_photo'];?>">
								</div>
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('registration_proof'); ?>:</label>
									<input type="file" name="registration_proof" id="registration_proof" class="form-control">
									<input type="hidden" name="old_registration_proof" id="old_registration_proof" value="<?php echo $driver['registration_proof'];?>">
								</div>
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('number_plate'); ?>:</label>
									<input type="file" name="number_plate" id="number_plate" class="form-control">
									<input type="hidden" name="old_number_plate" id="old_number_plate" value="<?php echo $driver['number_plate'];?>">
								</div>
								<div class="form-group">
									<label><?php _el('status'); ?>:</label>
									<input type="checkbox" class="switchery" name="is_active" 
									id="<?php echo $driver['user_id']; ?>" <?php if($driver['active_status']==1) { echo "checked";} ?> >
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
$.validator.addMethod('filesize', function (value, element, param) {
    return this.optional(element) || (element.files[0].size <= param)
}, 'File size must be less than {0}');

$("#profileform").validate({
	rules: {
		firstname: {
			required: true,
		},
		lastname: {
			required: true,
		},
		mobile_no: {
			required: true,
            number: true,
            minlength:10,
		},
		email: {
			required: true,
			email: true
		},
		licence_photo: {
            filesize: 2097152,
		},
		registration_proof: {
            filesize: 2097152,
		},
		number_plate: {
            filesize: 2097152,
		},
		vehicle_type:{
			required:true
		}
	},
	messages: {
		firstname: {
			 required:"<?php _el('please_enter_', _l('firstname')) ?>",
		},
		lastname: {
			required:"<?php _el('please_enter_', _l('lastname')) ?>",
		},
		mobile_no: 'Please enter a valid 10 digit mobile number',
		email: {
			required:"<?php _el('please_enter_', _l('email')) ?>",
            email:"<?php _el('please_enter_valid_', _l('email')) ?>",
		},
		licence_photo: {
			filesize: "file size must be less than 2 MB.",
		},
		registration_proof: {
			filesize: "file size must be less than 2 MB.",
		},
		number_plate:{
			filesize: "file size must be less than 2 MB.",
		},
		vehicle_type:{
			required:"Please select Vehicle Type",
		}
	}
});  

</script>

