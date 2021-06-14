<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold">View Drivers</span>
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
			<li class="active"><?php _el('view'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form id="drivr" action="<?php echo base_url('admin/drivers/verify_driver/').$driver['user_id']; ?>" method="POST">
		<div class="row">
			<div class="col-md-12 ">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-12">
								<h5 class="panel-title">
									<strong>Identity Details</strong>
								</h5>
							</div>
						</div>
					</div>
					
					<!-- /Panel heading -->
					<!-- Panel body -->
					<?php //echo "<pre>"; print_r($driver);?>
					<div class="panel-body">
							<div class="row">
						<div class="col-lg-3 col-sm-6">
							<?php if(!empty($driver['driver_photo'])) {?>
							<div class="thumbnail">
								<div class="thumb">
									<img src="<?php echo VIEW_DRIVERS_IMG.$driver['driver_photo'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
									<div class="caption-overflow">
										<span>
											<a href="<?php echo VIEW_DRIVERS_IMG.$driver['driver_photo'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
											<!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
										</span>
									</div>
								<div class="caption">
									<h6 class="no-margin">
										<a href="#" class="text-default">Driver Photo</a> 
										<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
									</h6>
								</div>
							</div>
							</div> <?php } else { echo "Driver Photo Not Available"; } ?>
						</div>

						<div class="col-lg-3 col-sm-6">
							<?php if(!empty($driver['licence_photo'])) {?>
							<div class="thumbnail">
								<div class="thumb">
									<img src="<?php echo VIEW_DRIVERS_IMG.$driver['licence_photo'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
									<div class="caption-overflow">
										<span>
											<a href="<?php echo VIEW_DRIVERS_IMG.$driver['licence_photo'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
											<!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
										</span>
									</div>
								</div>
								<div class="caption">
									<h6 class="no-margin">
										<a href="#" class="text-default">Licence Photo</a> 
										<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
									</h6>
								</div>
							</div>
							<?php } else { echo "Licence Photo Not Available"; } ?>
						</div>

						<div class="col-lg-3 col-sm-6">
							<?php if(!empty($driver['registration_proof'])) {?>
							<div class="thumbnail">
								<div class="thumb">
									<img src="<?php echo VIEW_DRIVERS_IMG.$driver['registration_proof'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
									<div class="caption-overflow">
										<span>
											<a href="<?php echo VIEW_DRIVERS_IMG.$driver['registration_proof'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
											<!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
										</span>
									</div>
								</div>
								<div class="caption">
									<h6 class="no-margin">
										<a href="#" class="text-default">Registration Proof</a> 
										<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
									</h6>
								</div>
							</div>
							<?php } else { echo "Registration Proof Not Available"; } ?>
						</div>

						<div class="col-lg-3 col-sm-6">
							<?php if(!empty($driver['number_plate'])) {?>
							<div class="thumbnail">
								<div class="thumb">
									<img src="<?php echo VIEW_DRIVERS_IMG.$driver['number_plate'];?>" alt="" style="height: 240px;" onError="this.onerror=null;this.src='<?=base_url() . 'assets/admin/images/no_image.png'?>';">
									<div class="caption-overflow">
										<span>
											<a href="<?php echo VIEW_DRIVERS_IMG.$driver['number_plate'];?>" data-popup="lightbox" class="btn border-white text-white btn-flat btn-icon btn-rounded"><i class="icon-plus3"></i></a>
											<!-- <a href="#" class="btn border-white text-white btn-flat btn-icon btn-rounded ml-5"><i class="icon-link2"></i></a> -->
										</span>
									</div>
								</div>
								<div class="caption">
									<h6 class="no-margin">
										<a href="#" class="text-default">Number Plate</a> 
										<a href="#" class="text-muted"><i class="icon-three-bars pull-right"></i></a>
									</h6>
								</div>
							</div>
							<?php } else { echo "Number Plate Not Available"; } ?>
						</div>

						
					</div>
					</div>
					<!-- /Panel body -->
				</div>
				<!-- /Panel -->
			</div>
			
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Driver Details</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<?php if(!empty($driver)) {	?>
									<div class="col-md-12">
										<div>
											<span><b>Name:</b> <?php echo $driver['first_name']." ".$driver['last_name'];?></span><br>
											<span><b>Email:</b> <?php echo $driver['email'];?></span><br>
											<span><b>Login Type:</b> <?php echo $driver['login_type'];?></span><br>
											<span><b>Phone Number:</b> <?php echo $driver['phone_number'];?></span><br>
											<span><b>Address:</b> <?php echo $driver['address'];?></span><br>
											<span><b>Vehicle Type:</b> <?php echo $driver['vehicle_type'];?></span><br>
										</div>
									</div>
											
									<?php }?>
						</div>
					</div>
				</div>
			</div>
			<div class="col-md-12">
				<div class="panel panel-flat">
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong>Verify Driver</strong>
								</h5>
							</div>
						</div>
					</div>
					<div class="panel-body">
						<div class="row">
							<div class="form-group">
								<label class="checkbox-inline checkbox-right">
									<input type="checkbox" class="styled" name="verify_driver" id="verify_driver" <?php if($driver['is_driver_verified'] == 1){echo "checked";}?>>Verify Driver
								</label>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>	
		<div class="btn-bottom-toolbar text-right btn-toolbar-container-out">
			<button type="submit" class="btn btn-success verify_submit" name="submit"><?php _el('save'); ?></button>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>

<script>
$(document).ready(function(){
	$(document).on('click','.verify_submit',function(){
		var is_driver_verified = 0;
		var user_id = '<?php echo $driver["user_id"];?>';
		if($("#verify_driver").is(":checked")){
			is_driver_verified = 1;
		}
		var socket = io.connect('http://34.204.81.189:30080/'); 
		var data = {
				user_id : user_id,
				is_driver_verified : is_driver_verified
			};
			socket.emit('driverVerificationChanged', data, function(callBack) {
				console.log(callBack);
			}) ; 
	});
});

</script>




