<!-- Page header -->
<div class="page-header page-header-default">
    <div class="page-header-content">
        <div class="page-title">
            <h4>
                <span class="text-semibold"><?php _el('add_store'); ?></span>
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
            <li class="active"><?php _el('add'); ?></li>
        </ul>
    </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
    <form action="<?php echo base_url('admin/stores/add'); ?>" id="storeform" method="POST" enctype="multipart/form-data" onSubmit="return validate(this);">
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
                                <input type="text" class="form-control" placeholder="<?php _el('store_name'); ?>" id="store_name" name="store_name">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_address'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('store_address'); ?>" id="store_address" name="store_address">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_latitude'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('store_latitude'); ?>" id="store_latitude" name="store_latitude">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_longitude'); ?>:</label>
                                <input type="text" class="form-control" placeholder="<?php _el('store_longitude'); ?>" id="store_longitude" name="store_longitude">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('service_category'); ?>:</label>
                                <select class="select" name="service_cat" id="service_cat">
                                <?php
                                    if(!empty($service_category)) {
                                      foreach($service_category as $category) {
                                          ?>
                                          <option value="<?php echo $category['service_category_id'];?>"><?php echo $category['service_category_name'];?></option>
                                          <?php
                                      } 
                                    }
                                ?>    
                                </select>
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_user'); ?>:</label>
                                <select class="select" name="user" id="user">
                                    <option value="">Select Store User</option>
                                <?php
                                    if(!empty($users)) {
                                      foreach($users as $user) {
                                          ?>
                                          <option value="<?php echo $user['user_id'];?>"><?php echo $user['first_name']." ".$user['last_name'];?></option>
                                          <?php
                                      } 
                                    }
                                ?>    
                                </select>
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_logo'); ?>:</label>
                                <input type="file" class="form-control" name="store_logo" id="store_logo" accept=".png, .jpg, .jpeg">
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('can_service_provider'); ?>:</label>
                                <select class="select" name="can_service_provider" id="can_service_provider">
                                    <option value="0">No</option>
                                    <option value="1">Yes</option>
                                    
                                </select>
                            </div>
                            <div class="form-group">
                                <small class="req text-danger">* </small>
                                <label><?php _el('store_banner_images'); ?>:</label>
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
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Monday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_0" class="form-control store_time" onchange="get_val(this.value,0);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_0" class="form-control store_time" onchange="get_close_time(this.value,0);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(1);" id="is_cl_1">
                                            <input type="hidden" id="hid_close_1" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Tuesday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_1" class="form-control store_time" onchange="get_val(this.value,1);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_1" class="form-control store_time" onchange="get_close_time(this.value,1);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(2);" id="is_cl_2">
                                            <input type="hidden" id="hid_close_2" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Wednesday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_2" class="form-control" onchange="get_val(this.value,2);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_2" class="form-control" onchange="get_close_time(this.value,2);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(3);" id="is_cl_3">
                                            <input type="hidden" id="hid_close_3" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Thursday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_3" class="form-control" onchange="get_val(this.value,3);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_3" class="form-control" onchange="get_close_time(this.value,3);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(4);" id="is_cl_4">
                                            <input type="hidden" id="hid_close_4" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Friday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_4" class="form-control" onchange="get_val(this.value,4);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_4" class="form-control" onchange="get_close_time(this.value,4);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(5);" id="is_cl_5">
                                            <input type="hidden" id="hid_close_5" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Saturday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_5" class="form-control" onchange="get_val(this.value,5);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_5" class="form-control" onchange="get_close_time(this.value,5);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(6);" id="is_cl_6">
                                            <input type="hidden" id="hid_close_6" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><input type="text" name="weekday[]" value="Sunday" readonly class="form-control"></td>
                                        <td><input type="time"  name="open_time[]" id="open_6" class="form-control" onchange="get_val(this.value,6);"></td>
                                        <td><input type="time"  name="close_time[]" id="close_6" class="form-control" onchange="get_close_time(this.value,6);"></td>
                                        <td>
                                            <input type="checkbox" class="styled" onchange="get_close_day(7);" id="is_cl_7">
                                            <input type="hidden" id="hid_close_7" value="0" name="is_closed[]" >
                                        </td>
                                    </tr>
                                </table>
                                

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
<style>
#schedule td, #schedule th {
  padding: 8px;
}
.error-lbl{
    color:red;
}

</style>
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
var BASE_URL = "<?php echo base_url(); ?>";

$.validator.addMethod("emailExists", function(value, element) 
{
    var mail_id = $(element).val();
    var ret_val = '';
    $.ajax({
        url:BASE_URL+'admin/authentication/email_exists',
        type: 'POST',
        data: { email: mail_id },
        async: false,
        success: function(msg) 
        {   
            if(msg==1)
            {
                ret_val = false;
            }
            else
            {
                ret_val = true;
            }
        }
    }); 

    return ret_val;
            
}, "<?php _el('email_exists') ?>");
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
            number: true
        },
        store_longitude: {
            required: true,
            number: true
        },
        service_cat: {
            required: true,
        },
        user: {
            required: true,
        },
        store_logo: {
            required: true,
            filesize: 2097152,
        },
        "store_banner_images[]": {
            required: true,
            filesize: 2097152,
        },
        can_service_provider:{
            required: true
        },
        // "open_time[]":{
        //     required:true
        // },
        // "close_time[]":{
        //     required:true
        // },
       
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
            required:"Please upload Store Logo.",
            filesize:"file size must be less than 2 MB.",
            // accept:"Accept only .png,.jpeg,.jpg files",
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
            required: "Please upload Store Banner Images.",
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

function validate(){

var AnswerInput = document.getElementsByName('open_time[]');
for (i=0; i<AnswerInput.length; i++)
    {
        var n = i+1;
     if (AnswerInput[i].value == "")
        {
          if($("#open_"+i+"-error").length == 0){
            var html = '<label id="open_'+i+'-error" class="error-lbl" for="open_'+i+'">Please select Store Open Time.</label>';
            $("#open_"+i).after(html);
          }
          if($("#is_cl_"+n).is(":checked")){
             $("#open_"+i+"-error").remove();
          }
        } else {
            $("#open_"+i+"-error").remove();
        }
    }

var AnswerInput = document.getElementsByName('close_time[]');
for (i=0; i<AnswerInput.length; i++)
    {
     var n = i+1;
     if (AnswerInput[i].value == "")
        {
          if($("#close_"+i+"-error").length == 0){
            var html = '<label id="close_'+i+'-error" class="error-lbl" for="close_'+i+'">Please select Store Close Time.</label>';
            $("#close_"+i).after(html);
          }
          if($("#is_cl_"+n).is(":checked")){
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
        } else {
            $("#close_"+id+"-error").remove();
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
