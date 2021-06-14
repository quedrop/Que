<!-- Page header -->
<div class="page-header page-header-default">
  <div class="page-header-content">
    <div class="page-title">
      <h4>
        <span class="text-semibold"><?php _el('orders'); ?></span>
      </h4>
    </div>
  </div>
  <div class="breadcrumb-line">
    <ul class="breadcrumb">
      <li>
        <a href="<?php echo base_url('admin/dashboard'); ?>"><i class="icon-home2 position-left"></i><?php _el('dashboard'); ?></a>
      </li>
      <li class="active">
        <?php _el('orders'); ?>
      </li>
    </ul>
  </div>
</div>
<!-- /Page header -->
<!-- Content area -->
<div class="content">
  <!-- Panel -->
  <div class="panel panel-flat">
    
      <!-- Panel heading -->
      <div class="panel-heading">
        
          <!-- <a href="<?php echo base_url('admin/orders/add'); ?>" class="btn btn-primary"><?php _el('add_new'); ?><i class="icon-plus-circle2 position-right"></i></a> -->
        
        
        <!-- <a href="javascript:delete_selected();" class="btn btn-danger" id="delete_selected"><?php _el('delete_selected'); ?><i class=" icon-trash position-right"></i></a> -->
        
      </div>
      <!-- /Panel heading -->
    
    
    <!-- Listing table -->
    <div class="panel-body table-responsive">
      <table id="orders_table" class="table table-bordered table-striped">
        <thead>
          <tr>
            
            <th width="2%">
              <input type="checkbox" name="select_all" id="select_all" class="styled" onclick="select_all(this);" >
            </th>
            
            <th width="2%"><?php _el('first_name'); ?></th>
            <th width="2%"><?php _el('last_name'); ?></th>
            <th width="2%"><?php _el('email'); ?></th> 
            <th width="2%"><?php _el('mobile_no'); ?></th>
            <th width="50%"><?php _el('address'); ?></th>
            <!-- <th width="2%"><?php _el('driver_note'); ?></th> -->
            <th width="2%"><?php _el('order_total_amount'); ?></th>
            <th width="2%"><?php _el('status'); ?></th>
            <th>Delivery Option</th>
            
            <th class="text-center"><?php _el('actions'); ?></th>
            
          </tr>
        </thead>
        <tbody>
          <?php foreach ($orders as $key => $order) { ?>
          <tr>
            <td>
              <input type="checkbox" class="checkbox styled"  name="delete"  id="<?php  echo $order['order_id']; ?>">
            </td>
           
            <td width="2%"><?php echo ucfirst($order['first_name']);?></td>
            <td width="2%"><?php echo ucfirst($order['last_name']);?></td>
            <td width="2%"><a href="mailto:<?php echo $order['email']; ?>"><?php echo $order['email'];?></a></td>
            <td width="2%"><?php echo $order['phone_number'];?></td>
            <td width="2%"><?php echo $order['address'];?></td>
            <!-- <td width="2%"><?php echo $order['driver_note'];?></td> -->
            <td width="2%"><?php echo "$".round($order['order_total_amount'], 2);?></td>
            <td width="2%"><?php echo $order['order_status'];?></td>
            <td width="2%"><?php echo $order['delivery_option'];?></td>
            <td width="2%" class="text-center">
           
                <a data-popup="tooltip" data-placement="top"  title="<?php _el('view') ?>" href="<?php echo site_url('admin/orders/view/').$order['order_id']; ?>" id="<?php echo $order['order_id']; ?>" class="text-info">
                  <i class="icon-eye"></i>
                </a>
              <!-- <a data-popup="tooltip" data-placement="top"  title="<?php _el('delete') ?>" href="javascript:delete_record(<?php echo $order['order_id']; ?>);" class="text-danger delete" id="<?php echo $order['order_id']; ?>"><i class=" icon-trash"></i></a> -->
              
            </td>
            
          </tr>
          <?php } ?>
        </tbody>
      </table>      
    </div>
    <!-- /Listing table -->
  </div>
  <!-- /Panel -->
</div>
<!-- /Content area -->

<script type="text/javascript">

$(function() {

    $('#orders_table').DataTable({
        'columnDefs': [ {
        'targets': [0,3,4,5], /* column index */
        'orderable': false, /* disable sorting */
        }],
         
    });

    //add class to style style datatable select box
    $('div.dataTables_length select').addClass('datatable-select');
 });  

var BASE_URL = "<?php echo base_url(); ?>";

/**
 * Deletes a single record when clicked on delete icon
 *
 * @param {int}  id  The identifier
 */
function change_status(obj)
{
    var checked = 0;

    if(obj.checked) 
    { 
        checked = 1;
    }  

    $.ajax({
        url:BASE_URL+'admin/orders/update_status',
        type: 'POST',
        data: {
            user_id: obj.id,
            is_active:checked
        },
        success: function(msg) 
        {
            if (msg=='true')
            {                           
                jGrowlAlert("<?php _el('_activated', _l('orders')); ?>", 'success');
            }
            else
            {                  
                jGrowlAlert("<?php _el('_deactivated', _l('orders')); ?>", 'success');
            }
        }
    }); 
}


function delete_record(id) 
{ 
    swal({
        title: "<?php _el('single_deletion_alert'); ?>",
        text: "<?php _el('single_recovery_alert'); ?>",
        type: "warning",  
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",       
    },
    function()
    {
            $.ajax({
                url:BASE_URL+'admin/orders/delete',
                type: 'POST',
                data: {
                    order_id:id
                },
                success: function(msg)
                {
                    if (msg=="true")
                    {                        
                        swal({
                            title: "<?php _el('_deleted_successfully', _l('order')); ?>",
                            type: "success",
                        });
                        $("#"+id).closest("tr").remove();
                    }
                    else
                    {
                        swal({      
                            title: "<?php _el('access_denied', _l('order')); ?>",           
                            type: "error",                            
                        });
                    }  
                }
            });
    });
}

/**
 * Deletes all the selected records when clicked on DELETE SELECTED button
 */
function delete_selected() 
{ 
    var orders_ids = [];

    $(".checkbox:checked").each(function()
    {
        var id = $(this).attr('id');
        orders_ids.push(id);
    });
    if (orders_ids == '')
    {
        jGrowlAlert("<?php _el('select_before_delete_alert', _l('orders')) ?>", 'danger');
        preventDefault();
    }
    swal({
        title: "<?php _el('multiple_deletion_alert'); ?>",
        text: "<?php _el('multiple_recovery_alert'); ?>",
        type: "warning", 
        showCancelButton: true, 
        cancelButtonText:"<?php _el('no_cancel_it'); ?>",
        confirmButtonText: "<?php _el('yes_i_am_sure'); ?>",        
    },
    function()
    {
        $.ajax({
            url:BASE_URL+'admin/orders/delete_selected',
            type: 'POST',
            data: {
              ids:orders_ids
            },
            success: function(msg)
            {
                if (msg=="true")
                {
                    swal({
                        title: "<?php _el('_deleted_successfully', _l('orders')); ?>",
                        type: "success",
                    });
                    $(orders_ids).each(function(index, element) 
                    {
                        $("#"+element).closest("tr").remove();
                    });
                }
                else
                {
                  swal({
                        title: "<?php _el('access_denied', _l('orders')); ?>",            
                        type: "error",                            
                    });
                }
            }
        });
    });
}
</script>
