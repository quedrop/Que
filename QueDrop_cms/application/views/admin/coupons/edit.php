<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_coupon'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/coupons'); ?>"><?php _el('coupons'); ?></a>
			</li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form action="<?php echo base_url('admin/coupons/edit/').$coupon['id']; ?>" id="couponform" method="POST">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('coupons'); ?></strong>
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
									<label><?php _el('coupon_code'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('coupon_code'); ?>" id="coupon_code" name="coupon_code" value="<?php echo $coupon['coupon_code']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('coupon_description'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('coupon_description'); ?>" id="coupon_description" name="coupon_description" value="<?php echo $coupon['coupon_description']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('max_usage_per_user'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('max_usage_per_user'); ?>" id="max_usage_per_user" name="max_usage_per_user" value="<?php echo $coupon['max_usage_per_user']; ?>">
								</div>
								<div class="form-group">
									<label><?php _el('status'); ?>:</label>
									<input type="checkbox" class="switchery" name="is_active" 
									id="<?php echo $coupon['id']; ?>" <?php if($coupon['is_active']==1) { echo "checked";} ?> >
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

$("#couponform").validate({
	rules: {
		coupon_code: {
			required: true,
		},
		coupon_description: {
			required: true,
		},
		max_usage_per_user: {
			required: true,
            number: true,
        },
	},
	messages: {
		coupon_code: {
			 required:"<?php _el('please_enter_', _l('coupon_code')) ?>",
		},
		coupon_description: {
			required:"<?php _el('please_enter_', _l('coupon_description')) ?>",
		},
		max_usage_per_user: {
			required:"<?php _el('please_enter_', _l('coupon_description')) ?>",
            number:'Please enter a valid number',
		},
	}
});  

</script>

