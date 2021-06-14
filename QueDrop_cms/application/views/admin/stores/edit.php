<!-- Page header -->
<div class="page-header page-header-default">
	<div class="page-header-content">
		<div class="page-title">
			<h4>
				<span class="text-semibold"><?php _el('edit_store'); ?></span>
			</h4>
		</div>
	</div>
	<div class="breadcrumb-line">
		<ul class="breadcrumb">
			<li>
				<a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
			</li>
			<li>
				<a href="<?php echo base_url('admin/stores'); ?>"><?php _el('stores'); ?></a>
			</li>
			<li class="active"><?php _el('edit'); ?></li>
		</ul>
	</div>
</div>
<!-- Page header -->
<!-- Content area -->
<div class="content">	
	<form action="<?php echo base_url('admin/stores/edit/').$store['store_id']; ?>" id="storeinfo" method="POST" enctype="multipart/form-data" onSubmit="return validate(this);">
		<div class="row">
			<div class="col-md-8 col-md-offset-2">
				<!-- Panel -->
				<div class="panel panel-flat">
					<!-- Panel heading -->
					<div class="panel-heading">
						<div class="row">
							<div class="col-md-10">
								<h5 class="panel-title">
									<strong><?php _el('stores'); ?></strong>
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
									<label><?php _el('store_name'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('store_name'); ?>" id="store_name" name="store_name" value="<?php echo $store['store_name']; ?>">
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('store_address'); ?>:</label>
									<input type="text" class="form-control" placeholder="<?php _el('store_address'); ?>" id="store_address" name="store_address" value="<?php echo $store['store_address']; ?>">
								</div>
								<div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_latitude'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('store_latitude'); ?>" id="store_latitude" name="store_latitude" value="<?php echo $store['latitude']; ?>">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_longitude'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('store_longitude'); ?>" id="store_longitude" name="store_longitude" value="<?php echo $store['longitude']; ?>">
                            </div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('service_category'); ?>:</label>
									<select class="select" name="service_cat" id="service_cat">
									<?php
										if(!empty($service_category)) {
											foreach($service_category as $category) {
												?>
												<option value="<?php echo $category['service_category_id'];?>" <?php if($store['service_category_id'] == $category['service_category_id']){echo "selected";}?>><?php echo $category['service_category_name'];?></option>
												<?php
											} 
										}
									?>    
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger">* </small>
									<label><?php _el('store_user'); ?>:</label>
									<input type="hidden" name="selected_supplier" id="selected_supplier" value="<?php echo $store['user_id'];?>">
									<select class="select" name="user" id="user">
                                    	<option value="">Select Store User</option>
										<?php
											if(!empty($users)) {
												foreach($users as $user) {
													?>
													<option value="<?php echo $user['user_id'];?>" <?php if($store['user_id'] == $user['user_id']){echo "selected";}?>><?php echo $user['first_name']." ".$user['last_name'];?></option>
													<?php
												} 
											}
										?>    
									</select>
								</div>
								<div class="form-group">
									<small class="req text-danger"></small>
									<label><?php _el('store_logo'); ?>:</label>
									<input type="file" class="form-control" name="store_logo" id="store_logo" accept=".png, .jpg, .jpeg" value="<?php echo $store['store_logo'];?>">
									<input type="hidden" name="old_logo" id="old_logo" value="<?php echo $store['store_logo'];?>">
								</div>
								<div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('can_service_provider'); ?>:</label>
                                <select class="select" name="can_service_provider" id="can_service_provider">
                                    <option value="Select">Select</option>
                                    <option value="1" <?php if($store['can_provide_service'] == 1){echo "selected";}?>>Yes</option>
                                    <option value="0" <?php if($store['can_provide_service'] == 0){echo "selected";}?>>No</option>
                                </select>
                            </div>
                            <div class="form-group">
								<small class="req text-danger">* </small>
                                <label><?php _el('store_banner_images'); ?>:</label><br>
								<?php if(!empty($store_banners)){
									foreach($store_banners as $banners){
									?>
									<div class="img-wrap" id="b_img_<?php echo $banners['slider_image_id'];?>">
										<span class="close" onclick="delete_banner_imgs(<?php echo $banners['slider_image_id'];?>);">&times;</span>
										<img src="../../../../Uploads/StoresS/<?php echo $banners['slider_image'];?>" alt="" class="bnnaer_img">
									</div>
									
									<input type="hidden" name="old_banners[]" value="<?php echo $banners['slider_image'];?>">
									<input type="hidden" name="old_banners_id[]" value="<?php echo $banners['slider_image_id'];?>">
									<?php
									}
								} ?> <br><br>
								<input type="hidden" name="delete_banner" id="delete_banner">
                                <input type="file" class="form-control" name="store_banner_images[]" id="store_banner_images" accept=".png, .jpg, .jpeg" multiple="multiple"> 
							</div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_schedule'); ?>:</label>
                                <table id="schedule">
                                    <tr>
                                        <th>Weekday</th>
                                        <th>Opening Time</th>
                                        <th>Closing Time</th>
										<th>Is Closed</th>
                                    </tr>
									<?php
									if(!empty($store_schedule)){ $i = 0;
										foreach($store_schedule as $schedule){ 
										?>
										<tr>
											<td>
												<input type="text" name="weekday[]" value="<?php echo $schedule['weekday'];?>" readonly class="form-control">
												<input type="hidden" name="schedule_id[]" value="<?php echo $schedule['schedule_id'];?>">
											</td>
											<td>
												<input type="time"  name="open_time[]" value="<?php echo $schedule['opening_time'];?>" id="open_<?php echo $i;?>" class="form-control store_time" onchange="get_val(this.value,<?php echo $i;?>);">
											</td>
											<td>
												<input type="time"  name="close_time[]" value="<?php echo $schedule['closing_time'];?>" id="close_<?php echo $i;?>" class="form-control store_time" onchange="get_close_time(this.value,<?php echo $i;?>);">
											</td>
											<td>
												<input type="checkbox" class="styled" <?php if($schedule['is_closed'] == 1){echo "checked";};?> onchange="get_close_day(<?php echo $i;?>);" id="is_cl_<?php echo $i;?>">
												<input type="hidden" id="hid_close_<?php echo $i;?>" value="<?php if($schedule['is_closed'] == 1){echo 1;}else {echo 0;}?>" name="is_closed[]" >
											</td>
										</tr>
										<?php $i++;
										}
									}
									?>
                                        
                                        
                                
                                </table>
                                

                            </div>
								<div class="form-group">
									<label><?php _el('status'); ?>:</label>
									<input type="checkbox" class="switchery" name="is_active" 
									id="<?php echo $store['store_id']; ?>" <?php if($store['is_active']==1) { echo "checked";} ?> >
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
			<button type="submit" class="btn btn-success" id="frm-submit" name="submit"><?php _el('save'); ?></button>
			<a class="btn btn-default" onclick="window.history.back();"><?php _el('back'); ?></a>
		</div>
	</form>
</div>
<!-- /Content area -->
<style>
#schedule td, #schedule th {
  padding: 8px;
}
.bnnaer_img{
	width: 100px;height: 100px;
}
.img-wrap {
    position: relative;
    display: inline-block;
    border: 1px #b5b1b1 solid;
    font-size: 0;
}
.img-wrap .close {
    position: absolute;
    top: 2px;
    right: 2px;
    z-index: 100;
    background-color: #FFF;
    padding: 5px 2px 2px;
    color: #000;
    font-weight: bold;
    cursor: pointer;
    opacity: .2;
    text-align: center;
    font-size: 22px;
    line-height: 10px;
    border-radius: 50%;
}
.img-wrap:hover .close {
    opacity: 1;
}
.error-lbl{
    color:red;
}

</style>
<script type="text/javascript" src="../../../../Socket/node_modules/socket.io-client/dist/socket.io.js"></script>
<script type="text/javascript">

function get_close_day(id){
    var n = id - 1; 
    if($("#is_cl_"+id).is(":checked")){
        $("#hid_close_"+id).val(1);
        if($("#close_"+n+"-error").length > 0){
            $("#close_"+n+"-error").remove();
        }
        if($("#open_"+n+"-error").length > 0){
            $("#open_"+n+"-error").remove();
        }
    } else {
		$("#hid_close_"+id).val(0);
	}
}


function delete_banner_imgs(id){
	var delete_val = $("#delete_banner").val();
	if(delete_val == ''){
		$("#delete_banner").val(id);} else {
		$("#delete_banner").val(delete_val+","+id);
	}
	$("#b_img_"+id).remove();
}

$.validator.addMethod('filesize', function (value, element, param) {
    return this.optional(element) || (element.files[0].size <= param)
}, 'File size must be less than {0}');

$("#storeform").validate({
	rules: {
        store_name: {
            required: true,
        },
        store_address: {
            required: true,
        },
		store_latitude: {
            required: true,
			number:true
        },
        store_longitude: {
            required: true,
			number:true
        },
        service_cat: {
            required: true,
        },
        user: {
            required: true,
        },
        store_logo: {
            filesize: 2097152,
        },
		// "open_time[]":{
        //     required:true
        // },
        // "close_time[]":{
        //     required:true
        // },
		"store_banner_images[]": {
            filesize: 2097152,
        },
    },
	messages: {
        service_cat: {
            required:"<?php _el('please_enter_', _l('store_name')) ?>",
        },
        store_address: {
            required:"<?php _el('please_enter_', _l('store_address')) ?>",
        },
        service_cat: 'Store Category is Required',
        user: {
            required:"Please select Store User",
        },        
        store_logo: {
            filesize:"file size must be less than 2 MB.",
        },
		store_latitude:{
            required:"Store Latitude is required.",
			number:"Please enter valid number"
        },
        store_longitude:{
            required:"Store Longitude is required.",
			number:"Please enter valid number"
        },
        "store_banner_images[]":{
            filesize:"file size must be less than 2 MB.",
        },
        // "open_time[]":{
        //     required: "Please select Store Open Time."
        // },
        // "close_time[]":{
        //     required: "Please select Store Close Time."
        // },
    },
}); 

$("#storeinfo").submit(function() {
		var sel_user = $("#selected_supplier").val(); 
		var user = $("#user").val(); 
		if(sel_user != user){
			var socket = io.connect('http://clientapp.narola.online:8081'); 
			var data = {
					user_id : sel_user,
					store_id : '<?php echo $store['store_id']?>'
				};
				socket.emit('supplier_change', data, function(callBack) {
					console.log(callBack);
				}) ;
		}
});

function validate(){

var AnswerInput = document.getElementsByName('open_time[]');
for (i=0; i<AnswerInput.length; i++)
    {
     if (AnswerInput[i].value == "")
        {
          if($("#open_"+i+"-error").length == 0){
            var html = '<label id="open_'+i+'-error" class="error-lbl" for="open_'+i+'">Please select Store Open Time.</label>';
            $("#open_"+i).after(html);
          }
		  if($("#is_cl_"+i).is(":checked")){
             $("#open_"+i+"-error").remove();
          }
        } else {
            $("#open_"+i+"-error").remove();
        }
    }

var AnswerInput = document.getElementsByName('close_time[]');
for (i=0; i<AnswerInput.length; i++)
    {
     if (AnswerInput[i].value == "")
        {
          if($("#close_"+i+"-error").length == 0){
            var html = '<label id="close_'+i+'-error" class="error-lbl" for="close_'+i+'">Please select Store Close Time.</label>';
            $("#close_"+i).after(html);
          }
		  if($("#is_cl_"+i).is(":checked")){
            $("#close_"+i+"-error").remove();
          }
        } else {
            $("#close_"+i+"-error").remove();
            get_close_time($("#close_"+i).val(),i);
        }
    }

    if($(".error-lbl").length > 0){
        return false;
    }
}

function get_val(v,id){
  if(v != ''){
      $("#open_"+id+"-error").remove();
      var endTime = $("#close_"+id).val();
      if(endTime != ''){
        st = minFromMidnight(v);
        et = minFromMidnight(endTime);
        if(st<et){
            if($("#close_"+id+"-error").length > 0){
                $("#close_"+id+"-error").remove();
            }
        }
      }
  }
}

function get_close_time(v,id){
    var startTime = $("#open_"+id).val();
    var endTime = $("#close_"+id).val();
    if(startTime == ''){
        $("#close_"+id+"-error").remove();
        if($("#close_"+id+"-error").length == 0){
            var html = '<label id="close_'+id+'-error" class="error-lbl" for="close_'+id+'">Please select Store Start Time First.</label>';
            $("#close_"+id).after(html);
            return false;
        }
    } else {
        st = minFromMidnight(startTime);
        et = minFromMidnight(endTime);
        if(st>et){
            $("#close_"+id+"-error").remove();
            if($("#close_"+id+"-error").length == 0){
                var html = '<label id="close_'+id+'-error" class="error-lbl" for="close_'+id+'">End Time must be greater than Start Time.</label>';
                $("#close_"+id).after(html);
                return false;
            }
        }
    }
}

function minFromMidnight(tm){
    var ampm= tm.substr(-2)
    var clk = tm.substr(0, 5);
    var m  = parseInt(clk.match(/\d+$/)[0], 10);
    var h  = parseInt(clk.match(/^\d+/)[0], 10);
    h += (ampm.match(/pm/i))? 12: 0;
    return h*60+m;
}

</script>

