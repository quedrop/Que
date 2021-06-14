<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('add_offer'); ?></span>
            </h4>
        </div>
    </div>
    <div class="breadcrumb-line">
        <ul class="breadcrumb">
            <li>
                <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
            </li>
            <li>
                <a href="<?php echo base_url('admin/offers'); ?>"><?php _el('offers'); ?></a>
            </li>
            <li class="active"><?php _el('add'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <form action="<?php echo base_url('admin/offers/add'); ?>" id="offerform" method="POST">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
            <!-- Panel -->
            <div class="panel panel-flat">
                <!-- Panel heading -->
                <div class="panel-heading">
                    <div class="row">
                        <div class="col-md-10">
                            <h5 class="panel-title">
                                <strong><?php _el('offers'); ?></strong>
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
									<label><?php _el('offer_type'); ?>:</label>
                                    <select name="offer_type" id="offer_type" class="form-control" onchange="get_values(this.value);">
                                        <option value="">Select any one</option>
                                        <option value="Discount">Discount</option>
                                        <option value="Delivery">Delivery</option>
                                        <option value="ServiceCharge">ServiceCharge</option>
                                        <option value="FreeDelivery">FreeDelivery</option>
                                        <option value="FreeServiceCharge">FreeServiceCharge</option>
                                    </select>
								</div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('offer_on'); ?>:</label>
                                    <select name="offer_on" id="offer_on" class="form-control" onchange="display_store(this.value);">
                                        <option value="">Select any one</option>
                                        <option value="Order">Order</option>
                                    </select>
								</div>
                                <div id="store" class="form-group" style="display:none";>
                                    <small class="req text-danger">* </small>
									<label><?php _el('stores'); ?>:</label>
                                    <select name="store_id" id="store_id" class="form-control">
                                        <option value="">Select any one</option>
                                        <?php
                                            if(!empty($store)) {
                                                foreach($store as $stores) {
                                                ?>
                                                <option value="<?php echo $stores['store_id'];?>"><?php echo $stores['store_name'];?></option>
                                                <?php
                                                }
                                            }
                                        ?>
                                    </select>  
                                </div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('offer_range'); ?>:</label>
                                    <input type="text" name="offer_range" id="offer_range" class="form-control" placeholder="<?php _el('offer_range'); ?>">
								</div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('discount_percentage'); ?>:</label>
                                    <input type="text" name="discount_percentage" id="discount_percentage" class="form-control" placeholder="<?php _el('discount_percentage'); ?>">
								</div>
                                <div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('coupon_code'); ?>:</label>
                                    <input type="text" name="coupon_code" id="coupon_code" class="form-control" placeholder="<?php _el('coupon_code'); ?>">
								</div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('offer_description'); ?>:</label>
                                    <textarea name="offer_description" id="offer_description" class="form-control" rows="5" cols="100"></textarea>
								</div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('start_date'); ?>:</label>
                                    <input type="date" name="start_date" id="start_date" class="form-control">
								</div>
                                <div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('expiration_date'); ?>:</label>
                                    <input type="date" name="expiration_date" id="expiration_date" class="form-control">
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
var BASE_URL = "<?php echo base_url(); ?>";
function isPasswordPresent() {
	return $('#newpassword').val().length > 0;
}

$("#offerform").validate({
    rules: {
        offer_type: {
            required: true,
        },
        offer_on: {
            required: true,
        },
        // store_id: {
        //     required: true,
        // },
        offer_range: {
            required: true,
        },
        discount_percentage: {
            required: function () {
               if($("#offer_type").val() == 'Discount' || $("#offer_type").val() == 'Delivery' || $("#offer_type").val() == 'ServiceCharge') {
                  return true;  
               } else {
                   return false;
               }
            }
        },
        offer_description: {
            required: true,
        },
        start_date:{
            required:true,
        },
        expiration_date:{
			required:true,
		},
        coupon_code : {
            required: function () {
               if($("#offer_type").val() == 'FreeDelivery' || $("#offer_type").val() == 'FreeServiceCharge') {
                  return true;  
               } else {
                   return false;
               }
            }
        },
	},
    messages: {
        offer_type: {
            required:"<?php _el('please_select_', _l('offer_type')) ?>",
        },
        offer_on: {
            required:"<?php _el('please_select_', _l('offer_on')) ?>",
        },
        // store_id: {
        //     required:"<?php _el('please_select_', _l('stores')) ?>",
        // },
        offer_range: {
            required:"<?php _el('please_enter_', _l('offer_range')) ?>",
        },
        discount_percentage: {
            required:"<?php _el('please_enter_', _l('discount_percentage')) ?>",
        },
        offer_description: {
            required:"<?php _el('please_enter_', _l('offer_description')) ?>",
        },
        start_date: {
            required:"<?php _el('please_select_', _l('start_date')) ?>",
        },
        expiration_date: {
            required:"<?php _el('please_select_', _l('expiration_date')) ?>",
        },
        coupon_code:{
            required:"<?php _el('please_select_', _l('coupon_code')) ?>",
        },
        
    },
});

function display_store(val) { 
  if(val == 'Store') {
      $("#store").css('display','block');
      $("#coupon_code").attr('readonly','readonly');
  }	else {
    $("#store").css('display','none');
    $("#coupon_code").removeAttr('readonly');
  }
}

function get_values(val){
  if(val == 'FreeDelivery' || val=='FreeServiceCharge') {
    $("#discount_percentage").attr('readonly','readonly');
  } else {
    $("#discount_percentage").removeAttr('readonly'); 
  }

  if(val == 'Discount') {
    $("#offer_on").append('<option value="Store">Store</option>');
  } else {
    $("#offer_on option[value='Store']").remove();
    $("#store").css('display','none');
  }
}

</script>
