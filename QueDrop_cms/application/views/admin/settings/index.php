<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4></i> <span class="text-semibold"><?php _el('settings'); ?></span></h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li class="active"><?php _el('settings'); ?></li>
		</ul>
	</div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
	<form action="<?php echo base_url('admin/settings/edit/').$settings['config_id']; ?>" method="POST" id="settings_form" name="settings_form">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel body -->
					<div class="panel-body">
						<div class="row">
							<div class="col-md-12">
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('service_charge'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('service_charge'); ?>" id="service_charge" name="service_charge" value="<?php echo $settings['service_charge']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('delivery_charge'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('delivery_charge'); ?>" id="minimum_delivery_charge" name="minimum_delivery_charge" value="<?php echo $settings['minimum_delivery_charge']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label>Minimum Express Delivery Charge :</label>
									<input type="text" class="form-control" placeholder="Minimum Express Delivery Charge" id="minimum_express_delivery_charge" name="minimum_express_delivery_charge" value="<?php echo $settings['minimum_express_delivery_charge']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('shopping_fees'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('shopping_fees'); ?>" id="shopping_fee" name="shopping_fee" value="<?php echo $settings['shopping_fee']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">*</small>
									<label>Shopping Fees Percentage:</label>
									<input type="text" class="form-control" placeholder="Shopping Fees Percentage" id="shopping_fee_per" name="shopping_fee_per" value="<?php echo $settings['shopping_fee_percentage']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('minimum_transport_time'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('minimum_transport_time'); ?>" id="minimum_transport_time" name="minimum_transport_time" value="<?php echo $settings['minimum_transport_time']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('driver_search_radius'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('driver_search_radius'); ?>" id="driver_search_radius" name="driver_search_radius" value="<?php echo $settings['driver_search_radius']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('order_request_waititng_time'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('order_request_waititng_time'); ?>" id="order_request_waititng_time" name="order_request_waititng_time" value="<?php echo $settings['order_request_waiting_time']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('order_request_accept_time'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('order_request_accept_time'); ?>" id="order_request_accept_time" name="order_request_accept_time" value="<?php echo $settings['order_request_accept_time']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('delivery_charge_per_minute'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('delivery_charge_per_minute'); ?>" id="delivery_charge_per_minute" name="delivery_charge_per_minute" value="<?php echo $settings['per_minute_delivery_charge']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label>Minimum Express Delivery Charge per Minute :</label>
									<input type="text" class="form-control" placeholder="Minimum Express Delivery Charge per Minute" id="per_minute_express_delivery_charge" name="per_minute_express_delivery_charge" value="<?php echo $settings['per_minute_express_delivery_charge']; ?>">
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
			<button type="submit" class="btn btn-success"><?php _el('save');?> <?php _el('settings') ?></button>			
		</div>
	</form>
</div>
<!-- /Content area -->

<script type="text/javascript">

var BASE_URL = "<?php echo base_url(); ?>";

$("#settings_form").validate({
    rules: {
        service_charge: {
            required: true,
			number: true
        },
        minimum_delivery_charge: {
            required: true,
			number: true
        },
        minimum_express_delivery_charge:
        {
        	required: true,
			number: true
        },
         per_minute_express_delivery_charge:
        {
        	required: true,
			number: true
        },
        shopping_fee: {
            required: true,
			number: true
        },
		shopping_fee_per:{
			required: true,
			number: true
		},
        minimum_transport_time: {
            required: true,
			number: true
        },
        driver_search_radius: {
            required: true,
			number: true
        },
        order_request_waititng_time:{
            required:true,
			number: true
        },
        order_request_accept_time:{
            required:true,
			number: true
		},
		delivery_charge_per_minute:{
			required:true,
			number: true
		},
	},
    messages: {
        service_charge: {
            required:"Please enter Serive Charge",
			number:"Please enter valid Serive Charge",
        },
        minimum_delivery_charge: {
            required:"Please enter Minimum Delivery Charge",
			number:"Please enter valid Delivery Charge",
        },
        minimum_express_delivery_charge:
        {
        	required:"Please enter Minimum Express Delivery Charge",
			number:"Please enter valid Minimum Express Delivery Charge",
        },
        per_minute_express_delivery_charge:
        {
        	required:"Please enter Minimum Express Delivery Charge per Minute",
			number:"Please enter valid Minimum Express Delivery Charge per Minute",
        },
        shopping_fee: {
            required:"Please enter Minimum Shopping Fees",
			number:"Please enter valid Shopping Fees",
        },
		shopping_fee_per:{
			required:"Please enter Shopping Fee Percentage",
			number:"Please enter valid percentage",
		},
        minimum_transport_time: {
            required:"Please enter Minimum Transport Time",
			number:"Please enter valid Transport Time",
        },
        driver_search_radius: {
            required:"Please enter Driver Search Radius",
			number:"Please enter valid Radius",
        },
        order_request_waititng_time: {
            required:"Please enter Order Request Waiting Time",
			number:"Please enter valid Time",
        },
        order_request_accept_time: {
            required:"Please enter Order Request Accept Time",
			number:"Please enter valid Time",
		},
		delivery_charge_per_minute: {
            required:"Please enter Delivery Charge Per Minute",
			number:"Please enter valid Delivery Charge",
        },
    },
});

</script>